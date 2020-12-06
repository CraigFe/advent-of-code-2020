serve:
	docker run -e POSTGRES_HOST_AUTH_METHOD=trust -it postgres

run:
	psql -h localhost -U postgres -Xqf main.sql
