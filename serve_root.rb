class ServeRoot
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    # Redirect any missing pages to the root route
    if status == 404
      env['PATH_INFO'] = '/' # All dynamic routes should serve index.html
      status, headers, response = @app.call(env)
    end

    [status, headers, response]
  end
end