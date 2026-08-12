const request = require('supertest');
const createApp = require('../src/app');
const notesRouter = require('../src/routes/notes');

const app = createApp();

beforeEach(() => {
  notesRouter._resetForTests();
});

describe('GET /health', () => {
  it('returns 200 and status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /metrics', () => {
  it('returns Prometheus-formatted metrics', async () => {
    const res = await request(app).get('/metrics');
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('http_requests_total');
  });
});

describe('Notes CRUD', () => {
  it('creates a note', async () => {
    const res = await request(app)
      .post('/api/notes')
      .send({ title: 'Milestone 1', body: 'Build the app' });
    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe('Milestone 1');
  });

  it('rejects a note without a title', async () => {
    const res = await request(app).post('/api/notes').send({ body: 'No title' });
    expect(res.statusCode).toBe(400);
  });

  it('lists notes', async () => {
    await request(app).post('/api/notes').send({ title: 'A' });
    const res = await request(app).get('/api/notes');
    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(1);
  });

  it('gets a note by id', async () => {
    const created = await request(app).post('/api/notes').send({ title: 'A' });
    const res = await request(app).get(`/api/notes/${created.body.id}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(created.body.id);
  });

  it('returns 404 for a missing note', async () => {
    const res = await request(app).get('/api/notes/9999');
    expect(res.statusCode).toBe(404);
  });

  it('updates a note', async () => {
    const created = await request(app).post('/api/notes').send({ title: 'A' });
    const res = await request(app)
      .put(`/api/notes/${created.body.id}`)
      .send({ title: 'Updated' });
    expect(res.statusCode).toBe(200);
    expect(res.body.title).toBe('Updated');
  });

  it('deletes a note', async () => {
    const created = await request(app).post('/api/notes').send({ title: 'A' });
    const res = await request(app).delete(`/api/notes/${created.body.id}`);
    expect(res.statusCode).toBe(204);
  });
});
