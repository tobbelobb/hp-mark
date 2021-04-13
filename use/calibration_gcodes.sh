#startups
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A15%20B15%20C15%20D15 > /dev/null # A15 B15 C15 D15
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G96 > /dev/null

# The real stuff
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B34%20C5%20D0 > /dev/null   # G95 A30 B34  C5  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B5%20C28%20D0 > /dev/null   # G95 A30 B5  C28  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A5%20B30%20C30%20D0 > /dev/null   # G95 A5 B30  C30  D0

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A15%20B5%20C5%20D22 > /dev/null   # G95 A15 B5  C5  D22. Brings her closer to xy=(0,0)

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B34%20C5%20D0 > /dev/null   # G95 A30 B34  C5  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B5%20C28%20D0 > /dev/null   # G95 A30 B5  C28  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A5%20B30%20C30%20D0 > /dev/null   # G95 A5 B30  C30  D0

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A15%20B5%20C5%20D27 > /dev/null   # G95 A15 B5  C5  D27. Brings her closer to xy=(0,0)

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B34%20C5%20D0 > /dev/null   # G95 A30 B34  C5  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B5%20C28%20D0 > /dev/null   # G95 A30 B5  C28  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A5%20B30%20C30%20D0 > /dev/null   # G95 A5 B30  C30  D0

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A15%20B5%20C5%20D35 > /dev/null   # G95 A15 B5  C5  D35. Brings her closer to xy=(0,0)

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A30%20B34%20C5%20D0 > /dev/null   # G95 A30 B34  C5  D0
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A28%20B6%20C26%20D0 > /dev/null   # G95 A28 B6  C26  D0

curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A5%20B5%20C5%20D42 > /dev/null   # G95 A5 B5  C5  D42. Go UP UP UP
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A20%20B20%20C20%20D15 > /dev/null   # G95 A20 B20  C20  D15. Go Down step 1
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G95%20A20%20B20%20C20%20D7 > /dev/null   # G95 A20 B20  C20  D15. Go Down step 2
