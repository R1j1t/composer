ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

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

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.16.1
docker tag hyperledger/composer-playground:0.16.1 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

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

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��.Z �=�r��r�Mr�A�IJ��e������6I HQ^9o-��HJ�d�x����4.�(E��	�*?���?�!ߑ�kz�U�(���U6�����K�t�� UKk;�Y���P��ݺmyf5�m���XL��Ѹ$�2���#1*�QE���HcR\y��;��F��=rm|�;��M����)��2�Њ��q�Ou�8k�P0'�5x��.�Mb4q���sY���uHkt��6H�N�H/hJ1Զe��O�ZYV�5��
g�c�M�[%5���H�\b�����c��}���-BWl]U�i�>̆ȝ�Ae<}����?ς(���)w��x��?a�]����1�,+�4f����r�����/��KQI����娸���'��Tt3R�N�s,��◟"��~��Mu-<_$������~1�y'|���3��jw���hX�Jl�,-���	�Oe��W�qa�����a��k6�.�%�V�-�L�50����K`��19�/	���?X��Æ	���Z����c�wR������E�L��  ������9��Oe�_C��������&E�BX��*q4[o�A�&1��F%�� �B�k]�9�B�M�NŰ�j���*bX�1]�;�=�n��m��"���aI6�|ݵ�.�^�!ޅ(u�e� ɳ��pݶ��@Në�5���I�Z��iy(~�*۰lְ���>���au� 6���$ݎeW�{�4Tq�ˊaiM��u���X�G;ԡ�|`��Nvͭx�Qa[k��a��6
��OM7
��5B@����N�61���t2D�bRJ��a��M��u?K�A�zY0�ANb,�WJ@���\,�ܰ��F����N��$ȥ��$K�����Ei������Q+�<S�:�좦n�Ud��uJ � �3Mݬ�_�q���g�����O�l
���B��qz�������ϣ/)IT�ⷠ>JC�W���Iz�"0a#�g�������(s5*�F+�õK��^���U�j�bQ�F뽤���w�5�k��A�A$�=棰>�0`�<�o����İN9b�'���6ڗ���#���S�r�	�̤E�Α������(���f�e]�!C��K�G1�s(�4��cE����@n��]V��^���6��|n�]�w��b�E���5���
���?e���Xg>�u�rA��2��H7�޽��%0៨�*�Np���xϘ8�D�Ny����X�}D�k^^-�X<r��A:q��U-�,V�
�:��l�����Ɣxt����?&��`,﨎)�/��(;�$9��$*����g>��I��6�o��{l�f��G�1�2x��6��6�g۔ (0~,�˥s��/�&\y3W�XJs���_A5�����v��1XY�B�\�,1[9tFnVMs���b)�Sx~v9���w��L��/�Fw���a�NE��h�-����p��4�"�V�G��Y�\�TV���\>��_����I��
z�����JFJ����j�d}��P����� ��{��'V��G�l���{$̶���5T K#�kU�ͣW?I/�U�DZ��ɔ��w�BЭ0�`�]�@��h~|Z 
?:���_~�?�����'�k[tKq��`��'��c�����󁻷��W�䷰Sά��ӉJq��a���*��V�
aQ	޸�&�E��!����ݻt ��T��������ܽ�sO���{b�[H7a@�B�j��-�@��`��/�Ιa���L������qA�/���ǟ�83͂i�?!cR�?�b���v�g�0m�G����"�
�K�hl�7;��P7�2�	�۶��m���Zج:a���!rJW{�ҳ.�B�<�pj1����ǖ�P�כ���_�OdK�e���ճK��Es����1F�=�(0"������਴w+�jc)�r����
��H�:�4,4F�%��m��H��K�k�i@�4	;5�yR��F�mR��ֱ�D~��iV����f@>";���?��#0�z]
��iu�N��0�~kp[�?˥�i�?u���OB\�1����0��G%x�Zs�Z�BD\\�u)fѣ�*����\/��f|�{�- !1,��i��,l����S�����L�,OkT+#En����,�B��T�c��,������ ��s���?��hM?����M��¡�C`�!Lύ�ht�n������H��QoC'R��P�G�_�4Q(F+@���<��.W�7�ù����ġ���C���e��h��_��[i��nj��:�B�O���^Ar�C0�(W�����=���iw,?�ڰg�`M��D|>�T�Y��QB��dI������+�o@�	2Bu�]��ӽ|�q��~�ev�����65I{�n�pA�y�ށ��b4�$1Ѕ�hz�?���w���E"̢nX���G��C@C�4�}�j�x�1�J�aˮ�ar�[m�P���hѥb�� ��mg�O�H��m��zm�!� S7��}���50t/kToT{IF�i��4�/���Zo�s!'*�%c�q��܁Z�|���_�`!�]�:"5��� 4���c�ﲈ��E����dc�&G""�2���c����W��jm5Aj�\Y��%QQ��V��EeA��j'*b��e%��ir�L�<��n�yR�f�ۤ��
Nd�2C!����l���x�I�����	��h�����ړ���Ҩ���::�d�ƃ�@��al��)�bj��3�W��2ƙ�b��J�2	|��j$�t?g�WF	�л��&U��:&���_ok��:��S�=���eQ�F%��$E^�������l2۲��.�F�w��K��.36���|�j����/
�z�+��?*�`t�_�/���f����
?g�;��D��o�jw���#��|�~���- K� %j�r�&�Km�k�rZ{��Pᵅ(#�U����^�Pдkj�v���]�]�}m�k�%��c�ߤ?64�h��͝|�r���Ї����/��8��؟���Y�u��.8=$4�A��������:n�18�㒲���|��������ٴ:� ���A�Kc���(����������}����������_�;�����D+�&�Rb����('p�R���D"V�$�a&�H䘜�$���儒H����"UVe�߿���=7NxI]�g��v۠;�`�,qK?pN���G?.s\�2�vu���K�-�V�A�����ҟ�%�o���݀�s�c�@��?-�������;h��8yh��j;K�������0�S$4�t'H����ގ��=�>|��3���u�_��G������]�MS��䏿(�%Q�b���	�����E�c���_PWC�BZ���mˠo��'/x\�A��{�x�%&���h���p�S������f=��(��@z��?t	�C���\�3�\6�R������r���TJ�Ru��K��\Q-x;�A�y�Int��q��4��N�~�۲�s�'Bp;�yf(��U��$���A�,s�����*���Fe�hU�o<|�9˞��~�VN@���xoj��w$�G���FY}�cX��F�{|���6��I縤�T$�l3�b'_�H��{s�5����
���)��|9'�s�!M;aiB/��yx�����Nj�(}�����9�?ϔ��q�u�d~kO�:���Tk)��r�0���[~�/�7�����w����pR9���I�a�����a�Ň�
}a�K�A6���qfl�
��r�z2��Hv?m��rB�g6R�๓�T�����V�Β{�F�T�Xۧ��[�h��Dqci��b�Mr��nč�~�o�[Y\-麒�Ǐ۝�j��9��n1v,g����I���Ϋ2�p[Mw2�Hg���f=��i_o�I���QOT5�rh����^3��Rsɖ}��x2�L�7��v�����n���Ύ-����.�Q6a�{y��F0�
u5��O��R���{o�2�O���W�yB9LD���x:���y��9H����z�^R�bV��[��V��3�N>�J�ͷ��],�ݔ���V�Eu��ɦ|��� ���e8��޶���n6�I���֏�
�7�o�����=�3=�o[�{޴��(|��?���7;~��/`N�?�����?�/

`q�s.0d'�h+s�Rs���&���MktrC�`jC���!���NnYz$�7+����z �ķ��qh�F6M���֞)y0�R�Z�OS��~����7ϳ8~~ �R���B�9�����+*]%ke�`S���ơ�oY^yG"��Hz��n�7�i�d�a�S����w�a_�׿���S�{JS��~���[�s��$nV7���K�fu��Y}$nV���C�fu��Y�#nV����;�fu��I�w�k�� ��O���)�o���?�򵛾�G߆�'M���s�a�o?��K��f'�9�캔�׷��Ꞗޫ��ؙlz��o�g�u/��M��w[�ǜ��=���y���A��hX�j�ŭ���k�-S��ێ�9�m�^��Z__v��9�ڽ���@��n҄��_��"�1�����}�B��OP�jwm�K��/�F�a�"MsP��yQsOh��n�mh���M�?˫��^C���  �����G���u�G!�&5��YĬU�Q���\��M\�W%��UdZU�r��di��Q�%N���*��gj@(m��n����Z�~�uS�|�M46�%B�5-ڋ�B��BP��aw܆�/uO�0V#ߴ���x0w�~"��{�YL#��e
�8���[�u��ő�;~���������G�6ث��_�!&������w�]��)D#��uԵ<;��/Ԟ��U�<� v�u��:�d/S�o[-�>��4�:���e?�Dضq�VH�/�։�3�Һ�n���T�c!X*�j oO�$��E�����x��&���(��9�t���A�IA�Y�?7��0���g��@��ܠy�n{�-�yl�ʮ��	�-�*@��]���3���裄�Fz�F�/.½�_^����g�q˪��i
w��ț��`SM��K����c'q*�שT¢dǎ��b'N"=�X �hi���nF�CblaX ��ĂB�5�{���J}^�W�-M�饒�{���߽��s�/��<ٽ��F���@�`lg�1D.tac`���I�9� 	yu~�OTkm��G7��!n�9�=�i�Нc�s�|�]	�8�K�`n*�d�'�
�z��(x�Ɩ�qIy�6I�&�/o���xs��v����@HC��e%�Ҥ4Q�+"�F�n� B<)��Gg��0����{Q�}e�-��'kNG�C�G��9�o��K�J�U<l!���G��ǟ��ݠ�b�j��s�������f@�S�u]Y�=�v]�T>����Gk$X6e��r�!Tj8��p@ S�SP�~?� ��l�}����HV�vI�&�a��C|YV��� ����.���x��]�0t�^�0G\�q�;m���D�p��q*HX��nU��������	���͑S�B��n
�7��BيK�.|g��@K��(�":5����nL�%����������#���:.^��xl��G��������}���_$��?��i�����N����T����|������~��F�O`���l������^~���O�]�ס�5�NRW>�N"O�U�I���J�T"�'R�'2j�J�d"���I�TZ!H��I������#"�~������?���g�����l�T>�~��Ǒ?�aߍE~/�����W�(��߼����.XD������.���[��>�5�Q������#�|�yϾ9���!�����ա^c�r��N7�l��)��u�t�>`4��?8�Tk5�>a�����ٱt��Ύ;�u����3c�+0�{�<�6�M��i5����%M
'��pR�����nZ-HÄ�0�.�{��i�P�ù]�9g̶[�qg�Y�C�/��N�F�
�C��	�>*��ay�%�3�>pr�p�����4<L�[�#��6������5��Ÿy��ݠ�g��F56��D�Ͱ������3TJ��h)jq�v����: �v��7ٱa�M�*�Z�^��X�˕g�ԙ��z3	2R}��r1��ͬǪt�eh0�Z~(�it$^�#��<����a�Yt37��/�1:S�%8^�iy�6NS�H�����t:�:E�雉����R{4��ǧ�M��@�i^�.&'Q�yb3m���g����K��dO'���e�˃�T���#�ۤ�Ҭ�h�u:?Jӳ��+s{09�Ǫ�a���>����w��Rj�3*�3*��3*a��^mh2�������P,;{���fG"Q�0'K"Y.wbF=;Z�;�"vV8ZJ~�Ġ�yу�D�о����칞�I;Pe7�������˟�~oYMNG�z>U���Y��席�:-��=Y�ofZr��
i��Q��O���Ⓣ\SJtꎡd�G�4ǎ)��Z�r����Y�O�cҽ�,�I�$,��ʳ�Q���D�"�'K��>����S�\�S��D�B`S.�I��0Ai�S��&��F햖�T�.�	j���R���F�0 U._98ԓ�N�2�V1%�c�ޠ��g�䐻�ʂ�������_�y9�Nd'�����K^��w=�/([��z	����J7���������E>�jzw�0����";~����E������;�my5�J䥠����;��()�w"��,t���7��S���~��#x?x��RVVZV�H+����YE�t�ʴe.U?J*���/�/Z��X����,�I�]'�2�s(H�sa�њ <}΅]Gks.�e]5��<��؛�H`�>�@��P0���DZd��',xf%8�q�=~-�ۍB�Y�Bj��&�{츪�NjX&YM�fJfH�+�/�{�0V���n��e�k��=�$h+�k-��������I��H�+.�I#�Ĳ��9���a�6��,]��HCfZ�
Y�
��t&�H2���t����e�R)[ʛ���l;�0�-�o���&(�r�f��i�H]�Gy����𐈉�Q*18� B�Qr�fM��%D�1�Y5�GD��H�'u�3�Z�I1��шN|�?�H���K�&e9P�k�b��Ú0-��t�bi�~}yF��_��o
���Ҧ��[҇����}_>bU1�#V���^�O�E�,ʆ	�x7�Ҝ���;v]z��C:�	������@n�Z�j"/!����D�-����3M2��*��[�|�ak�QC-��{��^k���27`S/�vǩ;,�Nk|����� �)��F��\8k�Wi�v\E�s�@�΁K,'L���&���s�2�Z5�k��|���^��?= k:��a$�<��l�(�� �^��� M�G骚���Bk 6�1Wl�fE���xg(�v�0��E@0+&��B�7�t�Kѽ�h��\#�'�#�l�2��e��3��u)M�E(H+A"�g��xt����aJJ_�g�GfoW��N���<��v�-!� a�]w�&�J�P�H`9��:T�}���׼��Fq�5���4U�RFk�e&\>6sY�����Sk��-��1!t��.G)�.��l���|�X��3K/�(Q�+P0_�l(�f�-������h�H*Q�FNM+΢��w���.;�RB(��7(�/�4Ch�"U��S�R[tG���2�*=b	��T�l�&�7��4���Tʎ�$�vm�pQ6a,�N���4*�Q�."�@/���ҏ"�:���^�f䍰�"���e�+��ʅ�װ��.ZW-{���b�?�_�~��#kj����y{�23Ȳ��#��~C_���"��`��>}J���)����#���"oF^�^!W�}>����3�C��ׇ��x��7�K���v� Y}}�цf@�!T�1�e�|��2�+ْW���8�4t;����y�79��LT�R�y����>��ґG�s�"_ʨ�`/����y�q�����L�s��_,?��'���r+����Bi��~P�8�~=�Y��S���5K7�˩��0dWQ�;���$Y�u��@I>�&�P���p�D�b��B<Ӏվ�~y=��1�3lB���ؼ{������*>���>����u�*��k�.���h?Y��oCǬ�E���yI�A��!g �1�[���� [����	�������R7\����v8.�-A]�"�2@����d��c,h��ZB�"��DE����E�Z����7�	T�f�.��]�7i�����G��e�.��8o�Vߜ
>R�̂���]<Q�2u�K��>@�_��W�jȶ�5LB�p.j<�?�B�����[� o�������!�Ƃ���}�!�ޙj�cd��f����A�5�}ظ4���FjDP�(�L����l d
� ?Y}�۶"��F�Kv��X�
*YÝ �j_�c-E�و�nP`�ub������z��$�bP7�N�QWK�>^7D����&U#���	�˵'3`���]y�!���;�4���	�v��a��Z��oݷME.�}�"L�+H��Ĵ,��__�1
[0y��h��٦"�i8��ȳh]��Uo�=�7���!�phH��^��Z�^��6o��	-)�O���8\V�+��5�Ke�gg�."���(l��Q>��%���	�>`��zW�&��,[W
��HWS
y �=A�%�ps�5��-�UH���Y�6�3I7����k��%v�M��@�$��ԫ­fq���+Jx�������v1po�m�4�V���d�NG�m?� 2 �"T�eX�	��㤵n�@=kdOL��0��&�`���h�W��5�"�q�-��Js}8n� ���!�
���17i�A�c��h���vX-��� �c姟�W��`��q���,�zu�K薲j�a�V,Ϋ��U�I�n]i_�b�F�����>�����7�al 8]6�����jD�� Qф�Yk�[l5AgWB$~������P���@� �b䁮�<��@�$�"V/��T���>���W�Q���i��&~]l� S�b����e��_��T#��&���6r�i*ނ�֡L����-�p�-x���F�혓��7�5��7�@H�ݎ(�B��v�Ax���mExS���'����y��l��K���?�"��?�x���ǭ<^��}�C�C�(�w]�dK�%�W�`��W�3�<�{�9�����,}##=��v7����[
6��!W���4 ����{���g9�t��W����^X��~�z$�T�^�Jʤ$�T*C�W�T/��u�j�PR=B�H9�gHE�ɽLRJ$ҪD&%{����0f�y�܀Vڇ�_?�l����A
r��j�j/�LH0`.́�x6�DF���$�r,���I!H5эII���DFM��ɴ�d���`$�5�R	))�``����m}���↷��m����ѳ��J����ƛ/<�{On����[�o�x	�z%�F��:��V�2W�KǥJ��r�Ǌ*O����+�,[���1�]����6�����
�m�_�u;y�;��\X��SY�$4�<�8�=vYn��L`�ho�Ѿ
�=X�+pw&j���f�}��5�F5��Oe�Kg�j�h}[.�u��vQ�,��õ�����0��-x�l��#j߾A��/�L9�a���{�R� ���r���q�DG��/g+�*�K,�4��Y�c��V+|Y|<���h4
�YGg�$:��<���OTV~0��ݣp^���M����6��= E�����s|��̉�J�@ �{��q���z�k��nH��R]�UZ,�����XV���yP�!�p�蓥E����9��Y���J3[`�O�/����"�S�t�h�%��0�7z����dX�9$L�O�7��N�G��������$ڛ�nG�픿1�׬�1��V�+]Q��H��W�[�ڂwJ@f�c�vi�廘�� 69�ƌC�[!�v�2��z	T�8�U�Ut[�lK����v�8`p�wy�/�L&�D�L@�
����u�s��Y�R�U�����w�?o�y���G_g��d*q7���|%�S�Y�߱;�߷��<�ۆՕ�6��6���?�����|�?I�6�?�������?�<�H��������E�(t���������s���͝����&�gz���%�ם�w+�m����we݉�k��_�ݻV�<\������7g1�*(ʯ�4�tU�v'�� ]y�UVV:Պ���ϰ߀s�.0
Q�6���Abh�E凁�s��!͢lD��C����U������t~n4��4v��H������I��럋�5K�y�M�v���#����=��1%n��h�����$�/�?�������X��ɽ����D�����H��v���;�r�-�g%��?_����X��	�r�i�&[q�k�������u:<�p�C��>|<�?φ��:�Q��O�Ǡ�_���8���O �W����of�~���������]��b��*P3��&��~>5����k�����������U�� T���?���O���O�W�f��S��aJ�:T���4�y%�{����_�N�����W�p�����0�Q	��|�m ����_#����� �����M��v�������k�߸��p���������[����B*[څp��Yֲ��kB���i�V?�����}�zڻw?o����v?���|3������}��}"+�� ��U�RJ�6�`�hڙ�Pya��L��\_(��[g�0�;þ1�Z+Y���~2�}q
�c��� �p_��|Y�D~d����=��q������q�T�HI�d(��2�oW�b�'�v�S�����̅�+�Z��9vM��d`ӇV�#�,�y����tgkߦh�45�|�w�,�y�5<竃��BKF�Hc'���݊������O�P���?��k�C��64��!%�j4��?�����J �O���O��T����p�U��/Kb����?��k�?6����h�?�!���&�������[W��}����N�<�#WUc��h;�~��'����g_����tr�Ŀ���k��Ѩg<����i4�Z��rc?�(&��T���ѧg�Fm�@���Ē����7�#r8����vL�&gO����y�/�|��� j<_�ϖ~)�F���_���K��m|��ǆ��U2�{%���Z�eE��PJ��|����A�	Aow���|��3A��&a�^���p��R �,P8��P\:�&}n���oh����?�_h��[��,O!�� ��s�&�?��g�)�����I�D���>Jc�R�R(�q^����z�ﳾOЄK3>Nx>J��O�!
w�8��������W�_����G]�!�;m�F�4cO��;�6<�"NEo��f���_�����/N��8N(��U�"��"���9�f�q��b�%D/;0R��r"I�`��.ax�vL�����7�A��[ф��?�C�����o�h����>4��a��64�����?�6��7��	���>�J�w��:�r봝�Ll"Gg������� �ۥ�,}�������A���	�ꗌ�s;��u���@��L|Q<;$���q��)��ٺ��[�9�t����!�J�-ϡ����8�q��ք���������0��_���`���`��?��������s��
�_xM�9�U������QL�]�w��f��&'�y~��,k��/��%���g�Um-~� ��?q �}x�U�����_��*r���; x����V�vk���Z�[|���C��Z����e��.MSw���[�>�u��A�����I�\p�U��%����2v��ま��_^�-������; �#�p�!�;�U|"��q���x���D�<+�C?�+,�φ�9�t�V3M��7c�	-����L)?j\D�����4��l��<QQ�p�u�lp엾К�՞�$�HR[$���~B��p�'�2�ڡ���H��:ߤZ���{m��Yб������>⛽h�����	��
|���0��\T��_����?n��0���h������W�J�2�����G��o�?�����������z�0���	��?�s=�r=�CIe7���Q�s]��I.dP�fC����m.��˅$b.톰��ah��4��B�����_g�W�����f�X8B%>���Y�r��'dI��T�e��K�lˣ�i��RK�J�A��{jcd�!��.�����1�L/�mr-8rD��=Ͷqn0=��t��%6��}+�p�c����S	>��ou�J�ߡ�����?AB��
4����?��U�j��6	d�7����u�?����`��"T������B;�!���4��Ġ�W^���}����~n'z����%�1I*������_�2�-��������gf�o�C~f����F�q��(��t��S�ܩ�����Uς�uWg��&����d�N�TNKd:��Bo;XM'�zlGsW�Վ�IBi��8�Bbu�Q2-�i��/ݸP��%4��"�^����~{��Xz�8��98��C���P7���}��ء��S=�u��S�1�ɶ�"����r���yH�n�QS���:-FR���N�bĠ+�I�t���� ���Ε�B㘣��&Zo��E$9����o�Xveh����=���&T���~������M�# ��&T��0�44��?��& ����7���7�C�����|�A	�� ����_�����r��� MA#����_��_ ��!�����?��FA�U��?������:�Q����'��W�&�?����� ��U���8��?����ׅ���!j�?����=�� �_	��Q#����k����/0�Q	���Q5����� ��@��?@�ÿz�������a��"4@��fH� ����_#����� ���X�M����H���� ��� ����W���p���s�F�?��kC���!�F#�����*�?@��?@�C��������J� ��%1������[�5���?����4��a��r4����}����������)4B�a���
4@���K���� ����_���� �?T�&�?�]Š���E�ϰ�F,F>�>G�DH`�.�$�˸��1�˹$I1��>����	�O�������������*�_��wu��?9P���6`1�*�` �i�撕G#ΐ��&6��t�>�;R�c����Ř�E�Nbf��x�٫��L���q���0F��ʾc�Bu�!eOzx7���tk����!��|[����Գ�p
�"�į���E���7M8�!��>�|��k��֊&�����C#��jC������j�~3>!������ï�#�Шs+ZE��UwH�D��[��rܽ��lt�/�N޺_���r�h���M[~8,� Y%#�-PD?�\%�ع�����(x�q�\�w�.��5i4$�];,PBU��~�-dJ��V4�����������~���߀&���W}��/����/�����z�?��@#�����Q�����5�7|�������~:!ĩx����Ȗ'V���7���W�gmw�v��N�y��:yK��؇����-���4i��;/F{����&J/������ ���8#��?��%���2�����%��,���r�L�r����w����������aw�B��������/yyuY`��|�ǣP�&��X���Pnb�e}6$�a�����/��&��cΞ��$mq�1o6���m�&��<8;�y<r��`�|"(�Y@`[n�
īu�
8O�]oF���X���b��~�]������������i'i�zN(C���������������#��_	���0�A�'�W����Jt��Ƣ�����O�8����	����}�������s�'dz4U��?�0���ȫ��_x���[������~���,a��	�`��]��_��ёx�%�CĿo��E���&]�K�t�����[<�������R�C����B���|���ҥ�	�K�r|+]�*�����ؒ��[B���*�ת�&�m���o	Þ���ke���ȈR�Ӎ��.���b�GS�=9��ĸ\���yΜ�mJ��N�m;�,�ĺd��a��!��bf���-�T�{����v���X!�˷�y���������2zmM|�LRl$�(0�`n퉖`�e��8�F�?�{�Z��ٗ��%���]�9�{�$�|"��Ab��}���G�
&Sޱ�ٌ;���!�8b�ي�XH�+�y�ݍWh}΍u�D�/���S�J�����^��G���A��"T���B=#\����!�r�c���$�sJ�(NG�ϐ���>壡�an��X ���&����������J�+��%:�����Q�=���0�x���<���G�(%
��#�_����ʷjy�\����+>���V�}G�����U�&�?�!����*A�P�k0�x�������?�_%x��7(o�?�k�O�����a$L/�̌gt�w�?ת����/urA=��n6�}��՟�~����n�?����&�/���K��쇼��gIn���:=�H�t�%�Fagi ="�'5�6�>ܠ�7ﵒ:ru�Ӽ��B?�u���|�F�r����D��'���޺�K�yP�s=��$ߎގ�-q�b����{^��i�1�ŔW櫒W��u?>����h��0kao6��C�fëE�Q�k�fe>�^���;4�����Mc�~���񺱟n� 1H�u��$4�S���I @BRn�o���vKN��n ��k%�PP��SU�T+��i��T�����ڪ�i�L+bm�I�[�1f���	I�ĥ�?0�7D`�)�VHE��Y�hY�G�lQ��j�LI����أ ]0��!8~�����{AD�������D����+��S��Z��J�f�䄑:��6d�s�|�P���y�d��>/[BՂ|�l��O�K��0��W��1����I�8}����@��h�R�WxL$ �C����a���1��@��� *�������g2�������a��v��֨��ޢU[U�B������>���<{��^�O���},���i����n��( �D9�w�L-?�֧¶��m�s�&~�����B�4r�|���i�
�/]9eG�۫	��L�W���Rx!��<�ʙ�t�{���׺4oV�Ĩ�uW��8߲��Z��S����9�`W��I�kWU��N�Ҳ%6Y+k��Yz\g��hY���B
/����a�G��#_c٠r��r|+mV,65��[MR���Z�k�30��k��\o)�u�X������-�`kҪ��M�8���`��M��a�e��hb����Pڴ�]�d�|��KEmƗLQ`XM���/tr>+c8Ft�eg˻�9}�7#	����7��	����������[�%����O�!J��A��D����?�G8�����?��O8���K��}8�H$�����_���Ǉ��&�K�����?��0������o0�;�/a������C������4H�3g��a�ψ��M��!!���?~��0���F���?����! �C����	�l�\�)"���0/D����?v�'/���C��	��"&D��_���?��	`����x�H���.�����H���A!����[�%��3g��������!�!��Y������ �?��0����/j��B����n�������!!��BĄD��g�����#�� �?��0�C����?��H���LN������/�O^�� �E�d�?����������������׋D�?���?1!N�7S��o�*t����_��K�g�3�����
Mช�YfBIJ�$z"k9B%M�h�,��LV��V4M�I`E�Xc24FS���t�{$��3�����G�{��-��[�V����/�X]`k\��m��N�́��<��W�)�h�t��-Tz��`yy��G�[���p*����U��F�7�l8\ݭYZ�N��"Rܲ���c]�4H�?C�:)��:M��2יSrm�j���q�+����r��gym+V���;e���;{��+<aH����?�C\�ߟ�Q�$ 	���!	���ć8��p���]�I���Ň���8I��U��$�!�!SI9EuA]��Ϭ��t��:'��"�g�I�ѝ-dŵ�ز�X�����+��_�3��z�bꥌ�^V�ޤ,qj�����rZX҄�]=]�=i�j���{*�a�3��7&�i��Fq��J�!�`�Wl��_0����/���_L�?PƈD�?�>�����������q��u�w���R[K�͢�u����ѳ뿻[�sn\�y�=Ё��agr����D����A��0���ەQ��I�O�5L1Y��RC-����id����d�0\4+��&���4q2RKZ�^e�6)�2��ܲƒuv����b���^�uz��5�.�����a
���Z�R����^vAb D��N�	�<k�O�|�%rO�@�XS`qv���K���VQ)��Z���F�5��b��Au�M6��/��X�nS��,x.�evj��n�I����t�P���(m$�]��5�}$A����^����=�(��c�؅���/8����g.�1���@d�ܸ��ڄ�����O`g��b(��Q V���⮀W����c��B��������E�㮋�����c����8�7$��a���i�G���?� ���?���������_��"A��� +�����_"�����p��X���>���a�G$x4�c�Hw���]7���5���.0�!=є���m��Z������~����������Őo��C?�'��k\���8����7�����2��)��^(1+��˩��T�����`]��x���DyTJ��96+�B��BV�)�fL�^V솋BY7E���~����=��"�~%Y�-L�M�&�ӊ)��b_*�KV�7���б�+�f;��\��e͡��5�E��Ţ�c]uȐ�a��:F�閷����Rkrc�`^+��i��T�����ڪ�i�L+bm�I�[�1f��� ���ǆ��߽E�㮋����n�������!I��߄� �"����_8��0������_���$��	�뿻E�㮊W	���n����0��1!A�����H����ǆ���|>��/�cy9�+%�g��U���u�[����������AP�O����hϕE{
S�� ���m@v�-���%�VE"�JV�KJ�f�ry�v��(���b*3����_�Y<��G^ۨe�F�P
�R�K��Ls"V�ӟ�@� �o�@� ���hl�fE}P�����-\d�y:1�"m��ɒ�{D�(x��U_c9�ŋ���b�W.�*nR�Z�S%m��4���!ު�a}�n�W#������	b�����]�����/	���/��@����2G2��a4��)���I�	��d��q����T
W4Lb0M�Ufh5�e�	M�^���������'���s��.3f:&ie��h�0;�_�v]�.��~����FY�ԑ�K���ܦ���HW�zJq\Ip�����J���HqF����I��ד2�˚Dj��5˾�)
�ɠ�CA�\��M[����T$������!V�.w�r$��C�/>$������;�n`�U�*����_|xN����cZ���2��`H>=#����[�z�/ԉ�(�p�鷖'����[j��.	�q�d����y��je@!���}j�e��\"��ɶn�V���U�Q��b�v�9�=g��6�X$���"��l�Ő��G����"��cD"����� �`�����_���8���I����/&<������;�W5�X릖&R�t����u6��o���1 ϩ��. 9-p? 5ӽ�4h)I�o2N��^����$Y�����@>�Y:�L�Y���tg�v�E�QN�zڎ�����r	ώS�e��Oyn��T�!���$6(��:��?�X	F��� ��l�W���0^ �0��<�?��*N6[���\�
"/�7XC�3�7di���sX��'�9܅-v�G3�sŤ>�#�t�oz���9�9Y�Iv�\R�NQ�~qg֔.=v;��ۺ���@��j!yJ��<%�Wz��B�O��R�IoD���(�����a�-������<�f?��	���'H�d �G��9�U������Ѹ�����l�`ԍc�>Z`����ŏM�[��9�#���MXܵ�ښ9WQ���4R�.�zm�|g�ss[��7��׵~�#�;��Dސ,K����]������~���G�Ţ�m1��vIf}a<�����/���xƗ]��?�&��?c�&�Р���?�WZ6��,y���
�Gm�L��Q�um���㚖�J�y�b�5�nO��ku�ɫ���ݠ����U�͗>�{eI@'��%]IF}CE��몠��那mw������7oQe�������������N���_����B�]�����JEWz�� ����U��ZX(�ϫ;���17���X�P��A�'��B�v���Qݹ:�U=�Է�}C���"��m�P���ܕe���������O�����~ʽ�.��~�5���~��\r�+Y����� �b��?.�'��U���^pw.=��#;�܃�����؍���}~���xT9qm�\��Fa��rpX�i�W��]�OF���7[�M�s�j��C�|����m�cS�k�&ߨ��ޞ��D���B~<,S��J�WO��ix����G?Z�������y�������� �g�)��N$�!`���(���㮝R�Wh���?C0���q��I2�����?|������+o��e���/����|�� n/�U��S���]��~��܇�.���^�桙�U�Gw�^����E��� {����IW=p��owa�o�~�[����waA#{�������e�2W%��V���?|ҹ-M�������8�pl���������
�K�������%���@c�{Aqˡ��7�[��gߗv�>i��-���o�k�Uצ<v�"}�Y�j���ģ���k�+Ř�O��C��O���;�md���@>�<��Tf���������d������"��2}�$����þo��괱��>�o�����^�a{��`��������7~�!����I��^_�g�����{8N��C��������w�8�bj[�<hA -`j�	���A�֡x�6a���O.0���|����W�à�L� \��W�'��u�#"HSr=�#����ޡn#���}�#z��(���3����Eopp7��@��s�]��CI�6�z���wW����>���k��>�g��8���K�_�N��]��X��b��hw\P�$�s,T�>���(���C�o�AL<00��&���*,�*|~�>��]��4D3_�C1|I�h�P�([��A���
^�n�А2Ï�5v�S��-ݝC��䚶�I�� ����O���z]�A�����/�~�>�?ڟ���7�>�%�R3!���O�dY�����N��|�\n�������8�����ͤ�v�;��W*�]fv{��*W��&��l��r���v�Q�*W����.��m����U ��nHD�+��@B�q��"n�8�{�>lw��f�g9t���z�����{��~��om��;[��'��|�?��ZK�B����8CG�������9N�W��̬��Hl��D[-H�C�l@��F�C��5���ib}�[��K��F�G�Zj���ӱ�>���!��>l�|����N%�AK��o����􍇆�����@���!�B�~��2}�cL��E�y�,���h����=\�H�Om�;%!�t�!�'+�jGc��V��ڶ���2��M�y�'�doS����\��ֳb}����Jyo���f�G�`  U�+���9�{Bm��|5���j�ѩ�׋�f83��r#���F3����@��hM�i��C� �raU(�Qd*�#*$��a�С��l���z�������Jt����2���*���ǘɑ����p^U34�y*7�9W_�v ��o���1��U��J�������a�z-!��f�g���On��G���h�`{���e�	Q�p�zH:G���6>{~��+��j�{�x���k��9](Q���=_����д�S��>�]&O�;����E�wt�}[{g7��J�Zk쩻|c��;�i�<�Y�>�s��T���9��,����it��ݜ������!�3��[�T?n#��{�s�'H~�j�+���j=o/�/�
.��aO���P����x�V�m���My"�܀���_����}ѝ�y�|./��*�z����4C�l����&�������� ��(�����W�?�9�}!����|g��杍�����%�'vw>�X6
�БpS�����F�Q�lDh��Ci�D� ��L��D�F(�ҍ0��w��68Y0�_�򃁡+x�� �xm/m�@��[pŪ�{��ě��⾽�Ϳ�E���j!Onm�Z���;x�i��o�L ��.��	�|�:����"�!�
���%,�5Y]�q\����/��/z���)��ԝ���@��sJ�Q������=2ffC�0�|vH�zE�f�E��Cˬ|�`;�+Z�ҶE���^�p����ֶ� ��~��~~,͗��Z>r��kM����csy�����B��.>�7UT�<��Ԟ]@�ϷpT�S�5��Mf�zw���{p��K.�,���]7*�Wh
�Œ���A4�pUn�S7�4�}�ӆu��kjnʮs�M�Lk�ǃ����gd����b:~,����E]+��=y0r��{m�W�h��v��Z�rbF&���*�oi��߁Kuu���V�� f�x�g�����IJh��;�S������輸���G�C[��rp�Q���'��P��
Q"l�h�k,[�6`�6Cu[���jLM�
Cu���G����Xj�d�����N!���%�-�}O��R9н�}�7��8J�a��m�t'{#hB�g��R=^������Egh��1zhώ�Z��ʈ���>�d�����;����Ǐ}�2m�p���ׄ�ñ���v�9D�]`cP���Q��%Ar�|H5t�2�'�1۹6�^Ҷ'g�i�0M�ٓb�HL9}(�ԕ���tQ�+�n��&���F�*�(ĳ$�Ö�fm�������)W�O�@�ΜZ��bQZQ ��9�U�w�e����!;#�O6��S f<ٓ���Rb�f�ջ�����s�≙��h�rٮf���-��ҾԆZ�-!� g��!�ߨC�R��1����?t�s���ز�N�jǊ�E�;�`ք���Fwl+C40(Ԧ7�р@��cJ�n?� kd�����n�̰v��j-T��;���AGs5:,�,�1TP�(��)7^1CG�6�5qNyEǑ���:BX�Ѱ�����C8ǏÏ"��Ǐ!��&�'Nd�O��1(�p(����(�;�<��XVU,a�����5�w��]��~��������q���b����.x���b��$��Ϲ��i���K��𯸿���/�����~����ן��;��ߣ�|{���[�w6~��
_E�.�5&]��c����&d&����F1� j�A*�q,hPL�e��jlX�h�m�����n�Ļ�����~����?}�ǟ���4���'�= ~; � ~+@������.�E����w�^��F��[��r6�����/K�<�o�����t|ىS#����s`�
�X��z.R!�n���pekd�#)��:�i4~���Kk
b6fPR���+s�,��,R,*��%W���je�*E6dұ��Љ�(�g�Ve;�A�Әu)�ؙ�R�L��{KR����%YF8�`=��᐀����D~8$����6Rw��:p��Q����d�1��z�5��|2	t4�բ�p�km���,�S3Gm�o	uv4-��5e�b%>0,C�\�P-���О'�I�:�N�d��AB�-g�R"��w��=�c�4��%A4�^x/�lW�<�I��t��V���G�Q�Z)z$����|��4;m�7)��,S�w���s��)�fÎߨtFњ,��8��v��g*�p�5`b���k�̸��Ra9yR-UFE>��A�+�G��8��(4��U�s����)��IYˎs����L�G�3� ��B�(�S��T,Y�\P1!���6����q*��6�T�ldzk	�������4�i�,re����N�i�ډ6�fxZ� \Ͱ��R4`�tZ�,;��,�^�up�?�hr�;��d��T����$�=�k{�;��mP-���T?ӭb�Y�������t��B�P}0�����hIj���a�lM�:�r4#�L`X �m��%0�������������hoX�ǡ���a1ӝ�������r.7����i6���X�M�[�6��%�1��+p &���Ƅ�y��F��~}+Y�ԯV���IL���V����^6=S̈́)dA�J�и��T^�	M�l�ȟ��}�RJ�4q�e��?\((�82;[��&e��v����F1֟�6;�bvx,U�1@��YL�P|��S���w5��pw��뫻��W6?��?��<ύ��b2���tf�Ne�#=T��+JgfL�����Pi��Ҽ~zU�DEf�ũ�F�C�6SSn��b�\�s���|s+�G��"!;��h�`R9��̧�REnl�Na{�'ç&L$G����p�c�;�Y�J|��ת��>c��t�b�1�?Ȅ�I�Ȧ��&$s{�:W�WrC%�@3.7��f�7	s=�)�l�����/n�"�!6�;���/m��No���X��^>�{n|��	���-'�#���a�4teF�'^�x��p۾��ߡ�;�5~��������o�؀my��M��5�l���Z����C��`鐋�ٛ���?�G������Q�]��2s$//l�8
OreK���YV8�����r���*�D�A露Di.�t �]Os�gE�\D�@�V\�s�]\@��G�T!:��И�q�� �%:��Lu��FzT6���ZjK��u}��p|���k�����o����A/�n�� ������Ȼ��`����==��[:_i&�b�[��HN�GP��D�lWy�֝�{`=�<�h�n� ٠��J��O��A����
���u+S@'�%5r� `�M�ߎ��6ch[�I?S;iƯ��Q�gb��=���ƅBC�r�s���_+��4�d�p&g�������<w�_���k�3'�Ĝ�w�x/�v�#�*���BP��fَ0�ƻ��a�4�N�{i����q�<��������kN����6�Ƹ���	�K�y:8�#K�&�IK6�<]KZ�qv�/��%-��ou�z�2Ъ�D7΀h1����b����� ��~X�u��z��J��lV�5&\��.XF�]�[�K��*���HOZFs�������NRZ��V���V,�>�/����K�xO9�d}_K���rE�Rh��`S��䣺$����2�V�̄��d�K��J6	�H��T�.�
�N������2q�$7�Hr�$纾��_����7���׉ז]7/�����\�̗������9�hQ�FC�>#6\��o����\�o���l�w�;��4L����GJ���5�-��p�ɓ'ԻO���7�k��l_C&^'^��Ed�G��B�/�jǐ>K�%�I/�J���W�ݔl��~�7Z&,��C�=pT���m�5܏�<��%|�9���_��ᑋ�39��5��,�%6��g�u���BFe�d��y������]7�]�;���Y����t�?s4�ޜ����A��%���@,�+>C^Ja-c4��+ ��LZ��>
l[�[� ��a*'	�1w�b�\��$��"���akp.t�})�Ӈ 8l��=�ضKZm�p�d�v�	�Ɨw�}s����HkZ�7�ev��Պ�"r�c�F�`�*��1J@�Ȳ�qLD�\X�5@S!9H�j8�1!��9Y;���XF�t�L�mՆW��Ƹ�-��ա-ٿ{��8S�\�=��FΘ�u�im�5���y�zg�p����BV(��L.����#Uk�[g��������P*=
��gR��KbIʩ\�┋H�=�K i����ٝ���É�G��Bjt�{-��3��3.dj��[9T��.�7#�ȣ��*�tx��S��lUxͥ����Ŭcp��O��;\+d���� �������Ê��������ؗg�=N������u�	b)^��r�q!ZI���K�pU�ω��q_?����(
�?�����8;�2�.��!k���UZW��V�t�m�m~Gb��f�r5Wܓ`���t�ҶZ��S�5D�У{R��!��yKee����2�K£B��Gϡ��*�T<���ys�e#a�J�w��3�(e�CD�^�.�^���9�/4J��S���,q��jw�ɞ]#\�6bL/�z�[�NL�S֋���+�.��ػ�%U�,��W��0ƴܑ3�J!�/�/��WPAQ�~ �Vz��ԩt�^�]���d�ʽ3�^94��5t���sw~o.������N����<��u"zM����<����Q��:͊_�Q���C�(�0��Ϳ��QG�#��W�]��!ވ�Di���$���O,�5���j���L&R����?��d42BE��L����k��ἒ�q��Gg���(��,յOUn�d�Td�珹�=�������g��
����.sW��� ���̿�o
GĹ��ff���I�}��?{f{���`��"ߨ�\k����P�o��A��ˮ$ t�շ�����nSB�ݶ�����3�	%Q"����U�I�j�A��1c,�)	K����H�߆�9S��T�_���S^XhT�ߝ�M�2�%�ل*�a�OxI�9��Hn�ۛ�0c��vL�ʛ�o�ps�/m�8 L����K�R�[c�5��2����2�z�J�������-�����Ak�����ʋd�#�$3L��s{&�^�4����o��*M*�����U��zy�¹���*"��'�SncHM�FC?��ȸsΕ�<;�E��ߏ�̑�{j��Y�i��ج'����v:��L�BV}����:��i�~����b����r8~��@�7:�.»�>(���^d�c{���`�߯����\?�&�N����	�����
�m�	F0c�L��۹�"���#��r���`hm+�h��u2����2�R��ë������a�ܛҎ����\P��C?���8�ЖjՋěsM�g&������j��g|��r����uX�m��LIr��y��x1�~�ls���D~����"�8l.��N2���-UO���s���,yȇA��s:����z�X��8�\r����z�&��Ss�]�L��}l����B��?�?�#���L�jF~�s��-�;��遝e�k{�H�]�M�
Kߌ��,�7���(�.�{�3�Pw��f��إ�^L��nZ����J;%��׵q���n������Ǿ:}~_�\(��1����7�u������K���P\T�_sT1��(�u����h���ŧ�/Ý>�D�����y��S�W%��G5������4W��r����.�q��K�P��������U��ڞӃ��P�ܿ��v�"|����zY#%h窠j�-~�a3R�[��m��mr��Mc8n�`�X��/Lq-��F�&ځ~ͱYIs9��$��Tೊ�u۝ �=�,��W#޸��?�_LW�X<S�z5q�3\{��=��`_��;<������x+�#�[����?(�:�Q�� ��vc
�?2������1�D����o���zO �{@��{�0~R��]�A����������8��OC�u����?p�G,��񿛆>0�A0�q����?+�eV&֫"�?����p�_��(��Y@1,���/j�N㿶m������o��w�����Ā8���O��H�����)��������o�$�_q��+��X����a�7�)(���*�&�J�Ra�}�[��X��gY�wG�GGL~���Ab�P�nU�e�n�y4?"t�b�!���U�/�W=�_i��	������Xpe�՛Rן�2��?��2g��k��%�S۰�0�Q�yb�˞wr��
�vۣU��\L2s�Q�;F}�݊���M��Sr+z�5g���rKY��+�|�T�����w&S�?R��K���N�	��ԟ��ns=���.����Y�X�x��.���M%��)C�X�O1��1�%�<D�������i�}��O�ǁ���;�I��W�?����`���I���t|e ��'��/����i��0�8�U�����8�S̽�� �ǁ��($�'D�Ɔ�����O����Q���o���hu�r�fuS����~��K{�����l޸;mS?|�i��6�|:mS,�����|��$�r�SO'ъxu�T/��c���u�:�p�-������Ϧ�g��3�7� ������)��*����y�F��=�{���ע/8T���&/��V��Zm�kW�L�yҗ{Sʥc��l?�e�2�u�y�3�2'�ak2�f��^!_m1���Mz@������v��(y<��p<�6۲Y��룙�)�)��zJ^c�2'��@�0�ĳȺY�y�b�\�]Rk�5*ie�?QeRU7
g�o+<�59E�RC �A#�h��v� �ꁥzlnl�LA�����x]v+s�d�(��է��.��R%Oa�My�*床N��2�a���^;I3�2>������B�G,H������'������
����?��cB���C�G�
���$���X����cq��,<i�q>�ɺ�'�lPδ������D�?u��O��� ������3D)+��R?���~z^��) ��cy���Od��1��򳙓��Ӟ_+�q��s��z�U�������Na9w��kO�^���i��P,V�-l�m�R�C�Rc����S�'�#y�%՝�G4˸+n��J]-���m��6�g{_�[��x�"���)���ܼ3u��*�������:d'��ΚKRp�z��+S�J�s�C����M�d��R�۵�;[���h�Hc��N+�O[4H�����!�_� 
K � ���m����a�?1���A%*f�����D������'���d����q ��31!�?!������T�?E��?�����/���!�?��'�7��۾��]���oo��ˍh\��I������������_��ޠ��+���z���z��Y2Y���;I��QS�+�Js��Bj!�J�m�B<��`�zF�zdE�%�Ä[�[�r���>�֖��*YM�ZUD't�[�����z� (��G�~�O���m|䴏��m��_`�!�9�������oo�O3���mX��L�3k�J��\IBKh��p�����͑͞<���#&�nV�3�Xa?�X��t�~�� ��������i��f��q���� ��k�i������ U�?i��(l��46��F�)�bY�@R�k���u��	�ft��t��i�"XBC��a�������>S��9T�t7��z���҈c;�������[�<-*�+S+	��#���-�o5q��RV�;{a���e	�+���yWolu�/,BМ5S0S�
�J��{�-s&e�܍��I����E���LI���v}�D����C*��C��X���to|=�����K���m�������Ꙍ�B6���,ݙU֢nM��N��ޜ�?�B�5�+��܄Q�{�~b�է�Jrcd�&� �$:3Ѧ�խ]�t[����ˣM���-<�s�z�!r�L��ڀ��H��O��oBH������b�����/��J���_���_���_��?`&�T���w��À�޲���3���$ݒ���f��TvL�������p���������V�A|kk�3g  �?q rm�><�7U�Rw�O���*�� \c;��fG�rيk����:�GH=[���'U�ִ�*4K�Aǳf�٭0�3'�U}R��Z�y�����)[u����b컞�B��ޯ���yO�}`͛b���O�������r�i֍ji��Z;��'�?,S���5�Us�dGv�<f 4c��
E���%��P��?/�?i@��!HbWF��fY�凛���g�}��O&�QA�X�M�V�.�t��
7��3Zv�����[)�=w����X������ՈKw�A�?�|`���_,�a��U��H-�������8�q ���� �?�����V���?��O@�G, ������OV�	���������FS��i(�G��:�p��Q�UU��I�`�<�7Uہ*���<k�����j@b�B��G��_����AM��ҲC��AG���w���+T=r\]u�]UH�AQ�o�YО��X߷Zr�ؖT��U9��zM�Z|m9Yx�����Fm��wi��s~ ��榬t:8[����J,���^�a�Ǩ��@�o,������o��1�Y�'QX�����n���bBL���xO!�������[��?&���\�矰����?���ǃ7�߃�_]��W75�[��9������-�捻�o��H�w�SO��"^#?�|��L�w������y�F��=�{�S��7c�K����Xi�k���]�2��I_�M)�.��^��ė�ʬ�e��Ψ�ʜ\T��ɄR�3Xz�|��H�2�7�)�K�'O�m��pd		�rG��`l�f����b=P7/�,�nVf��X--C��Zm�
EZ��OT�T��}T��)bG���Ds����W,�csck�e
e��^��[a�3%�Eɴ��>�v���(y
�lZ�sW)�Ut�H����&���ؐ����A�/!�d����)��_��K��	��b�O���?��&q��� �C�7�C�7������?w��@��׶�����������OXH	R��?�����X ���������l�׃�o�8���q�R��Q�C�1���)��cA�G��N�ǁ���q�?L	��?y���B������?q��,��?��ǂ4�?�C$������zp��Ă��?�CČ���G�(���� ������)������B�G,H���!����m�����������&������������ �@��@�����K��q�� ��׶�R�����R�� 3R��?��@�!���?���?$�������X��ϙ��������_*������������i��!�?9@�?��C���څ�)�����8�q ����;��6�����m�/�O��a�?���1̷5�`hm��L�@�<k�tR��,��Qt~��:A������0FUY�$)�/�W=��X���	�?!\������=��,�O���{��k(_B=5Xh4L��J���I���4Ը.��j�7�o�ł��r��7�&W8���
N�Sm.���PT&{�ang5�D�o4�=U�T�[�KS���mo�5��U��:�}�Pn�����������!�?�&���w��I"�?��!��?�!����L�7������%�����:�P��[k{Ŭ%/7[ByZ�%��E��s��R����k���+�Rۺs~�7g���o@/((b?y�AQQ��af�Ԫ��� *��iF�`�Ͼ���;w�.�3F����Όi��+N4�ሽ�<#��Q36X���mW?���Q7���t��aa�SMc�lV��Lel��ފz��w翃�[�����+^�����_��`��`����?�+@-�N>��A�}>~���O���'��%�-�rGN>?�R윿��������*�i"Mt"���:yK�����4��Ra��nc��1� hd���ab4�i�u�Bo�C����t�朝���N�DTnۧ��}���g疾.�{m7�_��5���������I�%]>[)V5���Ĺh!�h�������a )>O�w[3�����y��)���t�����:����~#(��D�h�S	?5vv �c�8���^@�V:i��dtGS�X	-om�8]�Щ ��8k�4�o��V�m��|�Y�����4�����;���/�����O�������?E�p�KA꿋 ��"|���S��x�e��w�?G���e��O^��;����RP�?�zB�G�P��e�w��q�_���g�dY��~�X�a�d�Q��-B�ZәGYw;p��|t�����-�C&�,]���\~�m�t����K/�,?��~�,?���j���[�~�.=K�o�e�j]^��kj	�:�d�{R�8����u�$��6Թ�r���)gh�.܎�t��b�T����i�ʹI�0q\#&�3��o!
���i�"lv��3�Z���!A��l�&�b���[������y��v��r[)��Ǣ"vn���Ž�SN����T��D�%���6*9�չ�B���
'6X�a�yHe��m5z��̱�I�������6�?�	f:���8	ǎxX"�dBb���KI��=���Kb�;�OTL���d��,�����n���c���`��$���8��}��<��x�&=!�»<M�����`�(�hJ�<��ـ	��/�b
�ݟ�:����9��+����q$6&���I���#�d���ƛ�C��ƈ��l"�/���r�ZA�#W�j��ߊO�����;����W��>u�G��?��JA����e��_������J��������y?�?c�ڽ<�:��d�\w�N�����z��A��4ԩ���]6�}�_����'����C����,����7��f�!o��*ٹG:Z�۳2k�J�	���l��SaI��%n���,��$i�V��~�^�Z��hx-53N��\m?佾���C�~�����$bq"�#�(��<}���xRƚ��Ec���&����QxJ;#�'z��r9 �^8��tԾ�(1����/�~ ��O���"�sG�l&�����a�s���Z���dp����~7�A����?��T�X��� dy����'��_�^1\F��x��{�� ��"�<��I0�g^����<ԡ�����+	��iv��Dhi��8vz�QP�ᢉ�n�ŕ���sd堑��.[��y�l�ﭨ��) ����2���x��M�e��w�����������8�_J��:�'������U�?��U����9��낲��/����?� ���n�W���?�u�&f��c�[-�o��x?���d��ҷ$������W�,n�*K{vQA~lK�H驔��O�\=�Jz���s��sʏ��\m�v���n]�v����k�����Yj_K��b��o��C^缜M�<���d�uv��[tZr�罽=�(�j�vC�a���px�R�F�n+�M��r"�m�#��D����Yw��mK�D���%�翪��ʖ(��}߹$;�����h1����F�5��x�Qn8�4cٰ�!���ĲnZwQ}��vc&Z޾��N�O�����4SM�;��DEF��6Km�ݞ���ңy��G��H��`u*v�+̈��	�������W�o�Ǩ���|*���"�������������p�[u(����v�E����A�k9��o����o���������2 ��#���������աl�� �z�����G��/��������p��OY��O���m�e��w��8��e���ݝ� ��%�$��k��� ���������/��?�B�����U�?I����o%�R��\����_9���"���@]�r!�AY��w�(�?� �?@��?|_�B���_��(��?
�P�o�W���?@�G)���DHe�E�� ��f��/�� ��� �����t�������j����_����QjQ�?��a��@��?@��?T[�?���KA��/Obh��P�o�W���?@�W)�	�C�E�E�����������/j��p�*B��/O�n����P�o�W������KB=�?`I�q�禌4ɱS?Ȑ"oQ<��Q���:ąg�8��7����WG��b����/���N�\ʢ�k��[��7�X-�ҥ�Fw-Z��[��ǅڐt��ހ��,{^��١p�?��1��l�c�Y��O!����o[�+^��{�*j�$y2�}�D�M�ϱI��41H[�&�0�뙒�`|k�tbMݱ�J�'+j��6��rt2�힐�Jf&?뽻7U����C�gu�l��-`׷����_u��C�Ou������2����mQ����:|d�'y�E�{��!��H�k����aa��bܖ��N���{���� mO�v/]��v��7�rI�zK���ȅ7��aA��a���`�fԟ���1��NO���9\yS2շ1֒s�ve��ފZ��8�oE�t��?��W���Ԣ��*�������?����@V�Z�?������6��I��꿶�Z��k���DW%���������~�DEҤ�Nd~*���ɯf��mqC��uw�08δ��5����Ӷ��/��!:��!��r<�"gt�	I�VG�N����Zxӌ�o��y��0js�+���gu������V�铖s���m��R�j�(Oc
�X��~�z��I�����"����7[���I�F��Z�!�4�q�|���"!��v�ٮ���:D�1ma;�˥2��Q���N�C�Oh�[��8'q-�Oc����#��@ǽv��]��k�ר��#��
����|4{�e�������?(��(���~������@y����u��	����j�'�;��p,�����C`U_��������x0��O)���_^���� ����������Ԋ�!�t���7�����R ������������JA��N��P�o�W���*C}���������_
�?J�o�?����������^�Hix�U�;b�Qp7���ʝ�
�y��(��ُ�`����i���ː2�q�@�0�;���m��}�������~*ٹG:Z�۳2k�J�	���l��SaI��%n���,��$i�V��~�^�Z��hx-53N��\�~������~�s������$bq"�#�(��<}���xRƚ��Ec���&�x�WLF�)�t�������{ሣ�Q[�71����/�~ ��O���"�sG�l&�����a�s���Z���dp�������_�����b|C@����_-���+C����!� e�����/8��@��A��U[�3��S��?��Z|G@����_-��!��+B����W��ɨE�����w���\��_�?���٘��^����i�=k��R��Z����E��7{�>��"XN�1���@^��c�?�M8��tg���Y�7/�Xnm��n�v-���r�s��b�k�PN�8��,j0��@;6(�hod7���>�\� �� r���n!]ш��:�LtC<(��t���D�n���L˅��>���Ȇ�����ݾ�؅D���lV�d�,�G#±���e��Q�Gܝ��?%�z����/ŷ���[�Ձ�)�>���JA���h.�(.�X/������,��$�!C�qx1A�sl(�9e�����¨�?:�����G����&���+�o�'wF:~��G�]7M�m3J�p�����'���X��A���m�����t�@��1�YS�gS�=�	������K��z�ؤ�Q��K|��sg7��?ߊ:����Y�]���@U}�7��C�Wj����S����C /e`���;���_u���/���\�;�)aSQ����s�^�vk�٤3�2�Hv��V���|b6�ކ̲L�����^`rA��C�v'W0#�p~��aӓ�:��63�][�z�]��X��iY,�ht\�$�oE=����/�c`�/կ�� W�Z���We��/����/����_��h�JP��0迊�;�7��X���Z� c��C'�H�w���k���뿗����@n��@�8�{��m<�A��P3*r�=-���3-6q�O�bT0����Ĳ�hۛ-���
���x�f��� �	jo��b.K��er�y�'�E�IO��hcIr���z��.:}M*,��y���@H����cq�����}�W�ǎx;ZS�|$���W$�@��o�J��U����C�NF�"H���c��ۻ��đ(�L~��HMi�Qkt�Z��ѩ�bB�!ѐNu:"����tP������T�W��>��>}.M(��軼?/j��p�^����֕M{�-r7s���w�G�[����4}�{}�Nڣ���V17��U�|����u�ӵupV����/�����J����C�;0�=��t��0B��o^U�����Re9��+*��$�j>"��0�0f��ZX����=ƌzSơQ��́�h��~���~�kr�ꌘQ/	�3��ȓB�I���8�{!u���p/c$�C���Mߎ"�U�� �Yc��RG6�����]�y������2^�"Lx#�*$��������I<77*"O���[E�?+���h}h'����up�xK8�({1"v��ۑ���p0���&�������#�OA��Y�F�����·o�e��.�'b�8��3o0�q��L����c�k@"{�A�,`/	i<&HwL]�T�%?�<��4T���iZ�f	��(:�Ή/��9�W�q(��.�T��;!�/Aᛜa�$���e�ev�ǍN���d-��<@�2@�DR`�^����S���r9���$~�q-�҈<C�jZ�!Q=;'p�C�
�P���'QF$�-��	���b �RF�Z�lU���=��0�*\��졐'eLX���l��۽��_��� �ث��'�Ӟi�/�͚��A<q����Ⱥ�1�ޠ�>�p�[��N�?��XAD�SQ��Y:���,�ϰ<OP�i�t�Q$��p��'6���nߚƄ���a�S���Q�wԓ���,�� A�%�-��=I�X.�'�Z�?跏��i��{h31S������ɰHBBb�PZlВ�$뵛v�ނ�Xt��%��:u-���:aYӥ�ͪ�4!.�8�F�������xp�
��3w�v���E<<>��Y'�Y��m�>?�<w�d�i�D	��`��U�gvz֠k��t��q����UOH��̤����e>�I�_e�KA�>^�����X�~2��c�'�]ɭ&.:��]��3i�.�



























�8���� 0 