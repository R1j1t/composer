(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else   
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� o&Y �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/���V�O����n��>Y�Wn��!��S��i�xEiyx��GQ�@I�$� (�ė�9�y�M���Z��:�����r���C�>���i7���`���2��q��)��+���������@�X�B�x%�2�f�?�S\.�$�J�e�B��}�W쭣�r�h5���/���u������O�*���k��O'^���r�I�8
�*�;Y?��{4%i�K��I�y�;��q��Y��������O#��9��`���M����4��됄�{.�P������4E2�k;E�(����}�ث�s�!������?^{��?^����H�����#8�!�5�����eb�-Z�<Hi�<�DQ��x�M��`���`5Jq-�j(�����LH-;��Oc7x~��+�\l�M�B ��������y>���>EѨ�(Ds�Ձ���x����d+!u#�dh�J3�'�m�//d])n���-Q�r�u��7��XQ^z����S�����h�t�t�s���FU�����qu�z��у{���QǞ���)x��yQ7dI��y��e�o<�nr���)K�Of}o�9�5��E����p5�Ϻ=M��-�!^�S�b�2�P�t ���0)�����e�C��Ny�NQ����������3� �
`�?�(��0�ݏ�N4@�U���7��x�깑�S8b	��+��+���B3	�\��{�p��[��Q��܂���@��5�?W'Nc9xkcŝ4�s�kf�7�n$m,lq�0�U�����\�O�"��$ͽ������Nip�3m�P<Q(t�RP(@d���*F����͡]_�w#�L	��0{�nq��V�����Mm@;a���K�*nG(�JK�2qs��3���58O���=!98�ģȓ����/z^ .ԏ���4<�\XR����G��H��eQV���I9h�71��oVL�̖�Q��@���Fc$J�Ms�<0
Q� 	�"xY����Ɂ\&�$�H�Kqc6˨�9�v��oX���[NҖ�FSŋQW2Y1��@�E#�3�^<�F�.����lx6���Y~I�g�����G��K���Q�S�U�G��?��X��e�5�g�;���@=2̛흺_���@�8��В��X>̐#q���^B�Џ��
|Hʑ�z E�����di���2s��I���:��2��4]�!�l��b��p��#v�D���[�NyM1GkH���5q"5q1u{����~o�yl��W�y.�V��
������2t����[���˶:U �U��ք9P�m�0<Z GZoi�rf�m qy���+ ���TɌ�\�A����}� ����堛��>�u�^��[��kSR�G�D������:��u�E��`f����d_��8�#�f5�7�~�&��� 7ؽߤی�	��97�~&׵d:\M�6��C%�u���|����]����'I���("��9�_���#4�V�_*����+��ϵ~A��9&�r�'Ђ*�/�$�O��!i���JA�S�����'}�p�/�l��:N�l��a��a���]sY��(?pQ2@1g=ҫ��.�!�W����PEv������vO��M
Zy8�XOP�Yǳ�>Wx�qpa��Q��Ë�?k�؂m�
f�dܐ����[&_z˖2�'�!rXm|�1�>��:ݎ,h��ܘ��%���_�[P�	v��lO�*��������?U�)�(�x�Y��2P��U���_���.����?������������R����=��f�GB��
Sz��Ђ���?�}0���C�f	����>�.to;M�w��q���G&]���dR�M��5�{&h�����Ρ"�1�+�0�C����ٰ�L�[��(�cД(�𸘠KnP�dՎ�cx�h]c��-���1"�H������ N4�Y8e�!9H϶�"�0y�J�^;w�	�)��P�&+����Q^p�ߙ�8>Z���ɠ	U��"�}�c�+~>4��~-&!oם�6;���gJ�Һ���r�c�����N�H�G2g)���:��9O�
�$+��V<�?�/��ό��*�/"�ψ����T���W���k�Y����� ���Q���\"�Wh�E\��������+��������!���Z� U�_���=�&�p�Q��Ѐ�	�`h׷4�0�u=7pqa؂�a	�gQ�%Iʮ��~?�!������+��\��2aW�W���X�plNl����{���6[�A�z�^��+����q�N+)54$wm'���ǫ{���(ǌ��v��7pD���������=n2�L?�SJN�v�*���x<�����?�b���j���A���y
�;�����rp��o?_�.�?N���/����ۏ/+���O�8Yɿ|��_�z��qC�����wX��p���O�Z�)�2�Y���ň��ǶI��)�B]�B<�`Y�����w]7��%� p|�eX��JC�|�G��?U�?�������Aj�h�(��P�A����0�.���]#M���/���4���v]wW����s)���aDn5f����Q�5#���n��������j=qMP��	ff�^���9�_�����*����JO�?
�+��|���}i�P�2Q��_��P�|�M X���R�Z�W���������]���X��a���ǳ�>�Y@���g�ݏ��{P����]P�z�F��=tw��ρnX�΁���~�9�Ѓ��6��2q�p��N�}1/�.���G��&1]���&�����k��4�Gx,�3��gr�CMf=Q'���7G����Q[x+.�K����Dӭ3�YO>�#ܖ�Q�2��8��n�u_;ms.���g ��ݚ�r.k)ZV�y:E��ڔ�9��t��nw�cC��B�w{�C ����䶷�<����à�bM p"�r65�y{WW\����Vd���Fg9�,3�V�֟��A��߃ j�;%6�NГr�&{+~f��ni���p�5��!��x����/m�����_
~���+��o�����Vn�o�2�����l�'�R����m�?���?�m�a��o��N2;M�p�g�?���qo(�g���@y�@wA޺d�d����5`�5M|��?�O΃���ɡ���-*�;��5Y/��Z�o�JOM���C|k�r�Z��0�SٌI2��u��(�Z"��r��դ��y��!�~��܇.���� ��Y>h��@�Dk�<�w�u7��+e0��j.uq�?%s9��V{f��!Wk����=h�t�0B��G�P��a�?������/q����T�W
~��|�Q��)	�1����ʐ�{���������G��_��W��������N�����0�z�s9�\��[w�?F!T�Y
*������?�����z��S���\���G�4�a(�R�C�,�2��`���h��.��>J8d��T��>B�.�8�W���V(C���?:������Rp����Lɖ�þeN�6;}�!Bs�m�me�E��#mѢ&/��1ќ��J;�����(���)�G�  �mow���c�o]�5�Oaz���z8#P�249�P�7�+u�Ŧ=4����^������Qg��>Z|�=~>��b�?=��@���_�`�Y���������O�S�ϾB��k#�K�6����Z��?]�^XL��vҩ{��_wuCW�5r�\ًdb�~�/��4^F�r}��V��I��e��7ͮ"~�����֫c;����$N���:�E#$���ϿNi�������MjWn���uԎ�]׮����jE0]��W���<�������z>��ڕS;m��z�7���]y�.�ƋM�?�k��Sݾ��)n�{���K?�Y�Q1*\��2�(pk+܎����r_V��.[]]uQ�i�����MG��
A��o���ϋ��׾�WD���e�ZQI��`�;j���y�av}�(�΢г/7�˃����·��ŗWK���Q��l/V`t�7E�p�xV{����ǒ�LZ�����q��q����N��+��o?�M�v�����U������g���W[ ����ߩ�y�Χ��ƛ�_kp���0N���R���ƹ.T���#��k���O4a���"D~��j��Ծ���}��?���Y����?V��Wtñ�E��������w�F���Y��{�@�Uő�m�n��ɦR��וU��f9�}�axgkxk�p�Y�gK�:�{W�U������\z;u�r;���[tgo��p
�:N�d'q�����q;�{�|WH$�T$`�"� @� �/@��~�VBˇ�Bh�-Z	�;�'�$3�����Jw�=�~��~��s��J��B���}ؼ�[0�t6g�Llr�pKn%$l"��U*��������芤�t.���Jgc�(	�m]=f�:y�P������fSd��c��E�E�V�i�G�h1�	A�$^���䜐�!&L3y��+����(� ����]��.A�F �5�� �ڱ�0�\��R\�k�7,�l�����P�Ǧ*i���G��a��~G��O�����/��-���[5�����+ĻE�3��}0���+7�EY=4��H�-����W�u�h[��F����[(��KS�*�&jb�f܂��8ۋ��)�M�76���-���y8���k9p�����4�����z_��.L�4`u���V����:��ݿ�)�H��^����%<��q�G�kJ�Ӛ�-�j:�[�T�ͤMX����'�N�>s�ܰ�Q0{:��拰�~|A���D���{f���2�xT�&����"L��a��h+�����t](8͹�-߆0U䕜���)��-�� }L�7��Mk��U��uT��|�j ��,	5:}�%.-��^���:r�h_/���YmI�7v�|�s�H�#מZ�4r�$�Lُۣ%)h��)3�%��t���^fLЊ�-�Y�x�F��AO4��lr��oK��	�>T�5����*���;[����:����-p�X�E5 ���>��Y�iѽ�@px��'o��ƆǺ�W����xqs����?��������?�/��iPں�si�����r�c�č'���7��y�!�t��}?�������"����@��a>!�	>`B����E�{G�����CW~���O=X��ۅ�\��S�r���� �<π�Bw>� �u����p��n�7pG^xx�������!_��|�����\<���M���M��殴D`��sܼ����	9��e!���L�|k�2'�Zפ�kM�4�O�0�z緅��"ׇɞ ��í�ލ���7��z��h��Ʃa��z�`)���gǜP�r��T�A�E�°X���e�by\ĉ\����9��-����G�l�lC�p%JSE����aT`�������q�e�lx�#\b�U�0O΄Wɂcv{k��H.��\k7S�<tJ�T}�f�8`�d�R��W3����Ҿ�G�i�R�^E�U��1��3zFC�~�a��V�#�!_��0a&�Ä݄	�|�D�ݏ����ѹM=!�ڛz�S�k~~K�)����FȺW�(%��x���c^2��$ӡ\Z��R����L���Hb����sa�P�q��k�=��\�η��bJ��Q�CV���,��fP���A*ҍ�x��S��^��+XBV��E�>�����ë���j2F3�X�'��lDI��8-+�z�����z��
7��T�D�%%��Ho3\��m4_}e�����ـuAY����BDKt��:���(�M�4��V�(��N<Z���>�u��H1J�3�̈́KIF��N ��ڨ���锅��h�&�FK�:`X�pE2�Q2K�rDxAv���u	��x60�)�/&�N�WC� PO/W�h���$f)�h\/�q����Τc� Vhs��TO{��<�EJ���$V)�p���W�����c0r�&q��y �y�ᩱ7-��F��_"�hPˊb�,�"�GI-^V�
�ԸV��ɖp�{�XBi�)����S���n(�Q���z����?�e<�\U�%e9"� �VY��.�q���!+Ut	e�<;(-����?�����ݖ����h�B�R�_��˱|Z�1l�����^�;NY܎���l�϶�϶s�4~�w��FW��]ȵ�;�d��^غc�
���Wi;�Lϐ�ʾ}.�6re>����EeE�v��v��滂l���^�����{چ-��B��9(�*a�<���#AԺ��L.�<�&1��ht���U�@�抺��WĎ�3�#MD��Kࢡ*�-��X��5�"����~�ocW�y�e7�mw�U��֛0��}������"�4jV͑�"�B�{��1���m���¼��)����up��4������1+V��)��A�� �����@��U �]V$}������D��?���y��6�ۇ�9/�K��/ϝ8tOL���Қ�Z�(��P������KJ�𠭎����h.:�Ok��xX���6]p�rd����κ��V��4�5gс<8�,DJLE�>���ޘ�UZ�2��}|L#b���\(+��VpLu�X<���0��h�/��R��Q��*E���t�MB%�,��5��Y��؃�a�If�d1A��2���99}3�Y����p�D4�j(��A��{��\||@�=�NjL�\�@s�D�#�@V,�	Ez@-������*�G}X��|�i����x82�x/$�AB
wd}�f0���P�vK��B���j4��8.5�� ��c����c�q���z��G��A��s��e��:&�)f>ӆ)0۳{y
>8��^䲝���yX�=,�����x�x�{[<,'��Ɖ�m:���#|����j�ԅ4o~~D,)����9,Py����6��A�YL�5(2��E�5gY���0�ryg�����"�v��#tX�c���݌!�O�ZG���zBɪ֧�V�`�����qt4�h��Q0&!E��`��X8m0�0B���E��}��b���q߁��p����'U�w1\Ԇ����E���rU�zcR�)�~%S#Ӣ.U�1��R3�ǃ(��������!��-x ��ӢQmV
�~��&=�f���]�yc�1�8�ތ�Tޏw1ⷑS�=�S��b���F!��l;7��V�.�w�8oȍ����=��ӭh��_�qߜ��4�I�j�h�{�>p�����������&�mA���\����ܨWY���U���"r��vso���ˏ�����z?����/~��{��^��s~r��ou���k�ws��c�D�s.�D�'�?��G���?o��;��~������w����#�_~2����y�^��'�_��s�"��I�$�b��[w�x��C�+z�+��D���\�]�Cw�������[������/�������#�a�K�+����gn��Ej�/j�C�t��M��	8�N�+���+��v��ӡv:�N�gs|�����|����q
R�&4� �J���E.h�o��U��Y�s ��[������>F�����ב��	/ ��q����)������p��5���#y��� 3���Ks�l�yZΜ'��̙q�8��93�q8�q�̜a����܎�97�;w��ڦ��W�<z�d�������s�p�p����W_(�  