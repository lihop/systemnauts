// This is the server.
const express = require('express')
const morgan = require('morgan')

const app = express()
const port = 5000

// disable cache resulting in 304
app.enable('etag')

//app.use(morgan('combined'))

app.get('*', (req, res) => {
	console.log(`${req.method} ${req.url} HTTP/${req.httpVersion}`)
	for (i = 0; i < req.rawHeaders.length; i += 2) {
		console.log(`${req.rawHeaders[i]}: ${req.rawHeaders[i + 1]}`)
	}

	res.setHeader('X-Powered-By', '<player-name>')
	//res.set('etag', 'yolo')
	res.send('Hello World!')
	console.log(res.getHeaders()['content-length'])
})

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))
