# embed-jinja/sample-falcon-app/main.py
import falcon
import os
from wsgiref import simple_server

from dotenv import load_dotenv
load_dotenv(dotenv_path='./app.env')

# Import your falcon resources here
class MyResource:
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.media = {'message': 'Hello from Falcon API!'}

app = falcon.App()

# FIX: missing comma between route and resource
app.add_route('/', MyResource())

if __name__ == '__main__':
    backend_port = os.getenv('BACKEND_PORT', '8000')
    # Jinja-Start
    # {% if env_name == 'dev' %}
    print("Running in dev environment defined via embed-jinja")
    # {% else %}
    print("Running embed-jinja with a custom defined environment {{ env_name }}")
    # {% endif %}
    # Jinja-End

    httpd = simple_server.make_server('0.0.0.0', int(backend_port), app)
    print(f"Serving on port {backend_port}…")
    httpd.serve_forever()
