"use strict";

// Cloud Function "nearbyPlaces": recomendações da cidade rankeadas por
// popularidade (Google Places API New), com cache no Firestore para minimizar
// chamadas pagas. A chave da API vem de um Secret (nunca no cliente/repo).

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const PLACES_API_KEY = defineSecret("PLACES_API_KEY");

// Região próxima + poucas instâncias (teto de escala = teto de custo).
setGlobalOptions({ region: "southamerica-east1", maxInstances: 3 });

const CACHE_DAYS = 14;
const RADIUS_METERS = 8000;
const MAX_RESULTS = 12;

// Categoria do app -> tipos do Google Places (New).
const TYPES = {
  attractions: ["tourist_attraction"],
  food: ["restaurant"],
  lodging: ["lodging"],
};

exports.nearbyPlaces = onCall({ secrets: [PLACES_API_KEY] }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "É preciso estar logado.");
  }

  const { latitude, longitude, category } = request.data || {};
  if (typeof latitude !== "number" || typeof longitude !== "number") {
    throw new HttpsError("invalid-argument", "Coordenadas inválidas.");
  }
  const cat = TYPES[category] ? category : "attractions";

  // Chave de cache: coordenada arredondada (~nível cidade) + categoria.
  // Assim uma consulta serve todos os usuários daquela cidade por CACHE_DAYS.
  const cacheKey = `${latitude.toFixed(2)}_${longitude.toFixed(2)}_${cat}`;
  const ref = db.collection("nearbyCache").doc(cacheKey);

  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data();
    const cachedAtMs = data.cachedAt && data.cachedAt.toMillis ? data.cachedAt.toMillis() : 0;
    if (Date.now() - cachedAtMs < CACHE_DAYS * 24 * 60 * 60 * 1000) {
      return { places: data.places || [], cached: true };
    }
  }

  // Google Places (New) — Nearby Search rankeado por POPULARITY.
  // O FieldMask enxuto controla o SKU (só o necessário).
  const response = await fetch("https://places.googleapis.com/v1/places:searchNearby", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": PLACES_API_KEY.value(),
      "X-Goog-FieldMask": [
        "places.displayName",
        "places.location",
        "places.rating",
        "places.userRatingCount",
        "places.primaryTypeDisplayName",
      ].join(","),
    },
    body: JSON.stringify({
      includedTypes: TYPES[cat],
      maxResultCount: MAX_RESULTS,
      rankPreference: "POPULARITY",
      languageCode: "pt-BR",
      locationRestriction: {
        circle: {
          center: { latitude, longitude },
          radius: RADIUS_METERS,
        },
      },
    }),
  });

  if (!response.ok) {
    // Deixe o cliente cair no fallback (MapKit) sem travar.
    throw new HttpsError("unavailable", `Places retornou ${response.status}.`);
  }

  const json = await response.json();
  const places = (json.places || [])
    .map((p) => ({
      name: (p.displayName && p.displayName.text) || "",
      latitude: (p.location && p.location.latitude) || 0,
      longitude: (p.location && p.location.longitude) || 0,
      rating: typeof p.rating === "number" ? p.rating : null,
      ratingCount: typeof p.userRatingCount === "number" ? p.userRatingCount : null,
      kind: (p.primaryTypeDisplayName && p.primaryTypeDisplayName.text) || null,
    }))
    .filter((p) => p.name);

  await ref.set({
    places,
    cachedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { places, cached: false };
});
