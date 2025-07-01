from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse
from authlib.integrations.starlette_client import OAuth
import os

from starlette.responses import HTMLResponse


def add_oauth_routes(fastapi_app: FastAPI):
    AUTH0_SIGNIN_URL = os.getenv("AUTH0_SIGNIN_URL")
    AUTH0_LOGOUT_URL = os.getenv("AUTH0_LOGOUT_URL")
    AUTH0_WELL_KNOWN_ENDPOINT_URL = os.getenv("AUTH0_WELL_KNOWN_URL")
    AUTH0_CLIENT_ID = os.getenv("AUTH0_CLIENT_ID")
    AUTH0_CLIENT_SECRET = os.getenv("AUTH0_CLIENT_SECRET")
    AUTH0_CONNECTION_NAME = os.getenv("AUTH0_CONNECTION_NAME")
    AUTH0_RESOURCE_SERVER_IDENTIFIER = os.getenv("AUTH0_RESOURCE_SERVER_IDENTIFIER")
    OAUTH_CALLBACK_URI = "http://localhost:8000/callback"
    REDIRECT_AFTER_LOGOUT_URL = "http://localhost:8000/chat"

    oauth = OAuth()
    oauth.register(
        name="auth0",
        client_id=AUTH0_CLIENT_ID,
        client_secret=AUTH0_CLIENT_SECRET,
        client_kwargs={"scope": "openid email profile"},
        server_metadata_url=AUTH0_WELL_KNOWN_ENDPOINT_URL,
        redirect_uri=OAUTH_CALLBACK_URI,
        authorize_params = {
            "audience": AUTH0_RESOURCE_SERVER_IDENTIFIER,
            "connection": AUTH0_CONNECTION_NAME
        }
    )

    @fastapi_app.get("/login", response_class=HTMLResponse)
    async def login(req: Request):
        return """
        <html>
          <head><title>Login</title></head>
          <body style="display:flex;align-items:center;justify-content:center;height:100vh;">
            <button onclick="window.location.href='/authorize'" style="padding:1rem 2rem;font-size:1.5rem;">
              Login to Travel Agent
            </button>
          </body>
        </html>
        """

    @fastapi_app.get("/authorize", response_class=HTMLResponse)
    async def authorize(req: Request):
        return await oauth.auth0.authorize_redirect(
            req,
            redirect_uri=OAUTH_CALLBACK_URI,
            audience=AUTH0_RESOURCE_SERVER_IDENTIFIER,
            connection=AUTH0_CONNECTION_NAME)

    @fastapi_app.get("/callback")
    async def callback(req: Request):
        tokens = await oauth.auth0.authorize_access_token(req)
        # print(tokens)
        access_token = tokens["access_token"]
        username = tokens["userinfo"]["nickname"]
        req.session["access_token"] = access_token
        req.session["username"] = username
        print(f"username={username} access_token={access_token}")
        return RedirectResponse(url="/chat")

    @fastapi_app.get("/logout")
    async def logout(req: Request):
        req.session.clear()
        logout_url = f"{AUTH0_LOGOUT_URL}&logout_uri={REDIRECT_AFTER_LOGOUT_URL}"
        return RedirectResponse(url=logout_url)

