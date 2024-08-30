const connect_to_db = require('./db');
const talk = require('./Talk');
const request = require('request');

const SPOTIFY_CLIENT_ID = process.env.CLIENT_ID;
const SPOTIFY_CLIENT_SECRET = process.env.CLIENT_SECRET;

module.exports.FindPodcast = (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    let body = {};
    if (event.body) {
        body = JSON.parse(event.body);
    }
    
    // Set default values
    if (!body.tags || !Array.isArray(body.tags) || body.tags.length === 0) {
        callback(null, {
            statusCode: 400,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Tags are required and must be provided as a non-empty array.' + JSON.stringify(body.body)
        });
        return;
    }
    
    console.log(JSON.stringify(body))
    
    if (!body.doc_per_page) {
        body.doc_per_page = 10;
    }
    if (!body.page) {
        body.page = 1;
    }

    // Connect to MongoDB
    connect_to_db().then(() => {
        console.log('=> Searching for related talks');

        // Find talks related to the provided tags
        talk.find({ tags: { $in: body.tags } }, { _id: 0, id_related_list: 1, title_related_list: 1 })
            .then(talks => {
                if (!talks || talks.length === 0) {
                    throw new Error('No related talks found');
                }

                // Extract unique tags from related talks
                const relatedTags = [...new Set(talks.flatMap(talk => talk.tags))];

                // Funzione per ottenere un token di accesso da Spotify
                function getSpotifyAccessToken() {
                    return new Promise((resolve, reject) => {
                        const tokenUrl = 'https://accounts.spotify.com/api/token';
                        const authHeader = 'Basic ' + Buffer.from(SPOTIFY_CLIENT_ID + ':' + SPOTIFY_CLIENT_SECRET).toString('base64');

                        const options = {
                            url: tokenUrl,
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Authorization': authHeader,
                            },
                            form: {
                                grant_type: 'client_credentials',
                            },
                        };

                        request(options, (error, response, body) => {
                            if (error) {
                                console.error('Errore ottenendo token di accesso:', error);
                                reject(error);
                            } else if (response.statusCode !== 200) {
                                console.error('Errore risposta non valida:', body);
                                reject(new Error('Errore ottenendo token di accesso'));
                            } else {
                                const data = JSON.parse(body);
                                console.log('Access token ottenuto:', data.access_token);
                                resolve(data.access_token);
                            }
                        });
                    });
                }

                // Funzione per cercare i podcast usando i tag
                function searchPodcastsByTags(accessToken, tags) {
                    return new Promise((resolve, reject) => {
                        const searchUrl = 'https://api.spotify.com/v1/search';
                        const query = tags.join(' '); // Combina i tag per la ricerca
                        
                        const options = {
                            url: searchUrl,
                            method: 'GET',
                            headers: {
                                'Authorization': 'Bearer ' + accessToken,
                            },
                            qs: {
                                q: query,
                                type: 'show', // 'show' è usato per cercare podcast
                                market: 'IT',
                                limit: 10   // Limita i risultati a 10
                            },
                        };

                        request(options, (error, response, body) => {
                            if (error) {
                                console.error('Errore cercando podcast:', error);
                                reject(error);
                            } else if (response.statusCode !== 200) {
                                console.error('Errore risposta non valida:', body);
                                reject(new Error('Errore cercando podcast'));
                            } else {
                                const data = JSON.parse(body);
                                console.log('Risultati della ricerca di podcast:', data);
                                if (data && data.shows && data.shows.items) {
                                    resolve(data.shows.items); // Restituisce i podcast trovati
                                } else {
                                    resolve([]); // Nessun podcast trovato
                                }
                            }
                        });
                    });
                }

                // Esegui le funzioni asincrone
                getSpotifyAccessToken()
                    .then(accessToken => searchPodcastsByTags(accessToken, body.tags))
                    .then(podcasts => {
                        console.log('Podcast trovati:', podcasts);

                        // Mappare i podcast per restituire solo i campi necessari
                        const filteredPodcasts = podcasts.map(podcast => ({
                            id: podcast.id,
                            name: podcast.name,
                            publisher: podcast.publisher,
                            description: podcast.description,
                        }));

                        callback(null, {
                            statusCode: 200,
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(filteredPodcasts),
                        });
                    })
                    .catch(error => {
                        callback(null, {
                            statusCode: 500,
                            headers: { 'Content-Type': 'text/plain' },
                            body: 'Errore interno del server: ' + error.message,
                        });
                    });
            })
            .catch(error => {
                callback(null, {
                    statusCode: 500,
                    headers: { 'Content-Type': 'text/plain' },
                    body: 'Errore interno del server: ' + error.message,
                });
            });
    }).catch(err => {
        callback(null, {
            statusCode: 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Errore connettendosi al database: ' + err.message,
        });
    });
};
