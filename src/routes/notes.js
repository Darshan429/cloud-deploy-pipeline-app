const express = require('express');

const router = express.Router();

// In-memory store — intentionally simple. This app is a deployment target
// for the DevOps pipeline, not the focus of the project.
let notes = [];
let nextId = 1;

router.get('/', (req, res) => {
  res.json(notes);
});

router.get('/:id', (req, res) => {
  const note = notes.find((n) => n.id === Number(req.params.id));
  if (!note) return res.status(404).json({ error: 'Note not found' });
  res.json(note);
});

router.post('/', (req, res) => {
  const { title, body } = req.body;
  if (!title || typeof title !== 'string') {
    return res.status(400).json({ error: 'Title is required' });
  }
  const note = {
    id: nextId++,
    title,
    body: body || '',
    createdAt: new Date().toISOString(),
  };
  notes.push(note);
  res.status(201).json(note);
});

router.put('/:id', (req, res) => {
  const note = notes.find((n) => n.id === Number(req.params.id));
  if (!note) return res.status(404).json({ error: 'Note not found' });
  const { title, body } = req.body;
  if (title !== undefined) note.title = title;
  if (body !== undefined) note.body = body;
  note.updatedAt = new Date().toISOString();
  res.json(note);
});

router.delete('/:id', (req, res) => {
  const index = notes.findIndex((n) => n.id === Number(req.params.id));
  if (index === -1) return res.status(404).json({ error: 'Note not found' });
  notes.splice(index, 1);
  res.status(204).send();
});

// Exposed only so tests can reset state between runs.
router._resetForTests = () => {
  notes = [];
  nextId = 1;
};

module.exports = router;
