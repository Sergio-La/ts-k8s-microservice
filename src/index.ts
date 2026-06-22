import express, { type Request, type Response } from 'express';

const app = express();
// Usamos bracket notation debido a la configuración estricta de TypeScript
const port = process.env["PORT"] || 3000;

app.use(express.json());

// Endpoint de salud para Kubernetes (Liveness/Readiness Probe)
app.get('/health', (_req: Request, res: Response) => {
    res.status(200).json({
        status: "UP",
        timestamp: new Date().toISOString()
    });
});

// Endpoint de prueba funcional
app.get('/api/v1/hello', (_req: Request, res: Response) => {
    res.json({ message: "¡Hola! El microservicio está funcionando correctamente. v2" });
});

app.listen(port, () => {
    console.log(`Servidor ejecutándose en http://localhost:${port}`);
});