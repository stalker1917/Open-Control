// By Stalker1917  LGPL 3.0
unit ControlConsts;
interface
const 
C_MaxPlane  = 3;
type 
TPlanesConst  = Array [1..C_MaxPlane] of Byte;
TAHStrings  = Array [0..3] of String;
TBFile  = File of Byte;
const
NPlayers = 7; //����� �������
NBuildings = 7;
BuildCols : Array [0..NBuildings] of LongWord = ($808080,$FFFFFF,$00FF00,$FFFF00,$FF0000,$008000,$0000FF,$AA0060); //�� ����� ���� ������-�� �������� �� ���� ������
LBaseArea = 25;
LArea = 15;
AreaPixels = 50; //���� 1000/LArea � �� ����� ������-�� 750/LBaseArea
BasePixels = 40; //1000/LBaseArea
BaseMine = 6;
HangarHigh = 6;
I_Regeneration = 25;
SectorDlinna = 1000;
SmallRadius = 18;
BigRadius = 36;
TimeToBase = 3600;
TimeToResources = 3600*36;

S_AviaFactory   = '����������� �����';
S_Hangar        = '�����';
S_BMine         = '����� �����';
S_GMine         = '������ �����';
S_RMine         = '������� �����';
S_VMine         = '���������� �����';



AS_AviaFactory  : TAHStrings = ('����� ������������','��������� ������','����� ��������','��� ������');
AS_Hangar  : TAHStrings = ('��� �������','��������� �������','����� �������','������ ��������');

H_Main          = 20000;
H_Bomb          = 1000;


Velocites : TPlanesConst = (5,4,3); // �������� ������ ����� ��������. 
C_Regimes : TPlanesConst = (0,1,2); // �������� ������ ����� ��������.

SaveVersion : Word = 1; //

var
CurrSaveVersion : Word = 1;//SaveVersion;


implementation
begin
end.
