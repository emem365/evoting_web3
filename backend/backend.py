from docxtpl import DocxTemplate
from flask import Flask, request, jsonify
import ipfshttpclient

#open the document
def replace_file(name, dob, aadhar, pub_address):
    doc=DocxTemplate(r'Voteris.docx')
    context = {
            "Name": name,
            "DOB": dob,
            "aadhar": aadhar,
            "pub_address": pub_address
        }

    doc.render(context)
    doc.save('result2.docx')

# connect to the ipfs client
res = ipfshttpclient.Client('/ip4/127.0.0.1/tcp/5001')

#flask app
app = Flask(__name__)


@app.route('/', methods = ['POST'])
def addfiletoipfs():
    try:
        body = request.json
        replace_file(body['name'], body['dob'], body['aadhar'], body['pub_address'])
        hash = res.add(r'result2.docx')
        return jsonify(hash), 200
    except:
        return jsonify({"error": "error"}), 400
if __name__ == "__main__":
    app.run(port=8000)
