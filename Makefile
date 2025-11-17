.PHONY: server css

server:
	python manage.py runserver

css:
	npx @tailwindcss/cli -i ./static/src/input.css -o ./static/src/output.css --watch
