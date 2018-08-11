# -*- coding: utf-8 -*-
import random
import socket
import threading
import unittest
from coapthon.messages.response import Response
from coapthon.messages.request import Request
from coapthon import defines
from coapthon.serializer import Serializer
from plugtest_coapserver import CoAPServerPlugTest
import sys
from coapthon.server.coap import CoAP
import afl

afl.init()
content = open(sys.argv[1], 'r') 
data = content.read() 

try:
    serializer = Serializer()
    message = serializer.deserialize(data, ("127.0.0.1", 5683))
    if isinstance(message, int):
        print("receive_datagram - BAD REQUEST")
    print("receive_datagram - " + str(message))

except RuntimeError:
    logger.exception("Exception with Executor")
except:
    print "Unexpected error:", sys.exc_info()[0]
    raise
