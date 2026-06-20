import express, {} from 'express';
const app = express();
// Usamos bracket notation debido a la configuración estricta de TypeScript
const port = process.env["PORT"] || 3000;
app.use(express.json());
// Endpoint de salud para Kubernetes (Liveness/Readiness Probe)
app.get('/health', (_req, res) => {
    res.status(200).json({
        status: "UP",
        timestamp: new Date().toISOString()
    });
});
// Endpoint de prueba funcional
app.get('/api/v1/hello', (_req, res) => {
    res.json({ message: "¡Hola! El microservicio está funcionando correctamente." });
});
app.listen(port, () => {
    console.log(`Servidor ejecutándose en http://localhost:${port}`);
});
//# sourceMappingURL=index.js.map