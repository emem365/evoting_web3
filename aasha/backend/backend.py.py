from docxtpl import DocxTemplate
from flask import Flask, request, jsonify
import ipfshttpclient

#open the document
def replace_file(name, dob, aadhar, pub_address):
    doc=DocxTemplate(r'template.docx')
    context = {
            "Name": name,
            "DOB": dob,
            "aadhar": aadhar,
            "pub_address": pub_address
        }

    doc.render(context)
    doc.save('result2.docx')

res = ipfshttpclient.Client('/ip4/127.0.0.1/tcp/5001')
app = Flask(__name__)
@app.route('/', methods = ['POST'])
def addfiletoipfs():
    body = request.json
    replace_file(body['name'], body['dob'], body['aadhar'], body['pub_address'])
    hash = res.add(r'result2.docx')
    return jsonify(hash), 200
app.run(port=8000)
