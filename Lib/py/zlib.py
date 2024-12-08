import zlib, sys, os
cwd = os.getcwd()
if len(sys.argv) < 2:
    print('Invalid argument length')
    sys.exit(1)
# inout file
inputfile = sys.argv[1]
if not os.path.isfile(inputfile):
    inputfile = cwd + inputfile
if not os.path.isfile(inputfile):
    print("Input file doesn't exist")
    sys.exit(2)
with open(inputfile, 'rb') as ibf:
    try:
        dd = zlib.decompress(ibf.read(), -zlib.MAX_WBITS)
    except:
        print("Failed to decompress the input file")
        sys.exit(3)
# output file
if len(sys.argv) < 3:
    outputfile = inputfile + 'o'
else:
    outputfile = sys.argv[2]
with open(outputfile, 'wb') as obf:
    obf.write(dd)
print("File decompressed successfuly")
sys.exit(0)