##
# Stage 1 - Build python dependencies
##
    FROM cgr.dev/chainguard/python:latest-dev as builder

    USER root

    ENV LANG=C.UTF-8
    ENV PYTHONDONTWRITEBYTECODE=1
    ENV PYTHONUNBUFFERED=1

    WORKDIR /app

    COPY pyproject.toml  .
    RUN uv sync --compile-bytecode

##
# Stage 2
##
    FROM cgr.dev/chainguard/python:latest

    WORKDIR /app

    ENV PYTHONUNBUFFERED=1
    ENV PATH="/app/.venv/bin:$PATH"

    # copy application files to WORKDIR (/app)
    COPY main.py /app

    # bring in the virtual environment / packages from the builder directory
    COPY --from=builder /app/.venv /app/.venv

    ENTRYPOINT [ "python","/app/main.py" ]