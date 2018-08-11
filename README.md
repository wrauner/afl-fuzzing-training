# AFL workshop training materials

GLHF

## Building

```docker build -t fuzzing .```

## Running

```docker run -it -v $(pwd)/workshop:/home/root/fuzz/workshop fuzzing```

## Open another console window

```docker exec -it <container_id> bash```

