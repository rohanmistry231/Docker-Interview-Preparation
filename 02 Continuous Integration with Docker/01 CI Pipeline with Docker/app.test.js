const request = require('supertest');
const app = require('./app');

describe('App Endpoints', () => {
    it('should return hello message on GET /', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toEqual(200);
        expect(res.text).toBe('Hello from the CI Pipeline Demo!');
    });

    it('should return OK on GET /health', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toEqual(200);
        expect(res.text).toBe('OK');
    });
});