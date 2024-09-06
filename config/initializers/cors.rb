# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
	origins '*' # Você pode substituir '*' por seu domínio específico para segurança adicional

	resource '*',
	  headers: :any,
	  methods: [:get, :post, :put, :patch, :delete, :options, :head],
	  expose: ['Authorization'],
	  max_age: 600
  end
end