from bottle import run, get 

# function to run the server
@get("/")
def _():
    return "Hej"

run(host="0.0.0.0", port=80, debug=True, reloader=True)