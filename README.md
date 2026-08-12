# CloudDeploy Notes API

A deliberately simple Notes API. It exists to be a deployment target for the
CloudDeploy CI/CD pipeline project — the DevOps automation is the point, not
this app.

## Endpoints
- `GET /health` — liveness/readiness probe target (used by Kubernetes later)
- `GET /metrics` — Prometheus-format metrics (used by monitoring later)
- `GET /api/notes` — list notes
- `GET /api/notes/:id` — get one note
- `POST /api/notes` — create a note, body: `{ "title": "...", "body": "..." }`
- `PUT /api/notes/:id` — update a note
- `DELETE /api/notes/:id` — delete a note

## Run locally
```bash
npm install
npm start
# API on http://localhost:3000
```

## Run tests
```bash
npm install
npm test
```

## Run with Docker
```bash
docker build -t clouddeploy-notes-api .
docker run -p 3000:3000 clouddeploy-notes-api
curl http://localhost:3000/health
```

## Milestone 1 exit criteria (from the roadmap)
- [x] `npm test` passes locally
- [x] `docker build` succeeds
- [x] Container runs and `/health` + `/metrics` both respond
