from flask import Flask
from flask import request
import os

app = Flask(__name__)

@app.route("/")
def index():
    value = request.args.get("value", "")
    if value:
        miles = miles_from_km(value)
        kms = km_from_miles(value)
    else:
        miles = ""
        kms = ""
    return (
        """<form action="" method="get">
                Unit value: <input type="text" name="value">
                <input type="submit" value="Convert">
            </form>"""
        + "Miles: "
        + miles
        + " / Kilometers: "
        + kms
    )

def miles_from_km(km):
    try:
        miles = float(km) / 1.609344
        miles = round(miles, 3)
        return str(miles)
    except ValueError:
        return "invalid input"

def km_from_miles(miles):
    try:
        km = float(miles) * 1.609344
        km = round(km, 3)
        return str(km)
    except ValueError:
        return "invalid input"

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
