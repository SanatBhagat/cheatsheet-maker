import express from 'express';
import multer from 'multer';
import { execFile } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import cors from 'cors';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());

// Auto-create uploads directory for the cloud environment
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}
const upload = multer({ dest: uploadDir });

app.use(express.static(path.join(__dirname, '../frontend')));

app.post('/api/generate', upload.single('pdf'), (req, res) => {
    if (!req.file) return res.status(400).json({ error: 'Please upload a valid PDF.' });

    const inputPath = req.file.path;
    const outputFilename = `cheatsheet-${Date.now()}.pdf`;
    const outputPath = path.join(uploadDir, outputFilename);
    const pythonScript = path.join(__dirname, 'process.py');

    execFile('python3', [pythonScript, inputPath, outputPath], (error, stdout, stderr) => {
        if (fs.existsSync(inputPath)) fs.unlinkSync(inputPath);

        if (error) {
            console.error(`Error: ${stderr}`);
            return res.status(500).json({ error: 'AI processing failed.' });
        }

        if (stdout.includes('SUCCESS')) {
            res.download(outputPath, 'micro-cheatsheet.pdf', (err) => {
                if (fs.existsSync(outputPath)) fs.unlinkSync(outputPath);
            });
        } else {
            if (fs.existsSync(outputPath)) fs.unlinkSync(outputPath);
            res.status(500).json({ error: 'Unexpected system error.' });
        }
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Engine runtime active on port ${PORT}`));
