# Spark QA Helper

## Available commands:

`generate-gifs` - generate animated GIF from Email Render UI Test reference images and Failed Test Case output image.

```bash
$ sparkHelper generate-gifs -h

OVERVIEW: Command to generate GIF images from images produced by failed Email Rendering UI Tests and corresponding reference images.

USAGE: spark-helper generate-gifs [--source-path <source-path>] [--destination-path <destination-path>] [--delay-time <delay-time>] [-o] [--verbose]

OPTIONS:
  -s, --source-path <source-path>
                          Path at which reference images are stored.
  -d, --destination-path <destination-path>
                          Path at which generated GIFs should be saved. (default: ./GIFs)
  -d, --delay-time <delay-time>
                          Delay in seconds between swithing from reference image to actual result. (default: 0.5)
  -o                      Open destination directory on finish.
  -v, --verbose           Print error logs.
  -h, --help              Show help information.
```
