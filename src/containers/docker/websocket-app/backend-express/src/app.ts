import express, { Application, Request, Response } from 'express'
import * as socketio from 'socket.io'

const port: number = 3001
const app: Application = express()
const expressServer = app.listen(port, function () {
    console.log(`App is listening on port ${port} !`)
})
const io = new socketio.Server(expressServer);

app.get("/", (req: Request, res: Response) => {
    res.send("Jello World!")
})

app.get('/toto', (req: Request, res: Response) => {
    res.send('Hello toto')
})

io.on("connection", (socket: socketio.Socket) => {
    console.log(socket.id, " has connected!")
})
