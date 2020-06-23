# Ig

## Working instagram basic display Oauth implementation, with posts fetching

Things mostly happen in those files : 

[InstagramAgent : responsible for most of the work](https://github.com/documents-design/instagram-basic-display-elixir/blob/master/lib/ig/instagram_agent.ex)  
[InstagramScheduler : refreshes posts and tokens](https://github.com/documents-design/instagram-basic-display-elixir/blob/master/lib/ig/instagram_scheduler.ex)  
[InstagramPost : converts responses to a struct](https://github.com/documents-design/instagram-basic-display-elixir/blob/master/lib/ig/instagram_post.ex)  

The controller exposes those routes :

`/api/instagram/start_authorization` gives you the URL to trigger the Oauth modal   
`/api/instagram/authorize` is the Oauth callback URL  
`/api/instagram/posts` is the list of posts in json  

Feel free to reuse & adapt.

## Phoenix doc

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Source environment vars with `source .env`
  * Start Phoenix endpoint with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
