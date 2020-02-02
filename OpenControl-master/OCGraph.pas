
Unit OCGraph;

interface
uses AreaManager,ControlConsts,Graphics,VCL.Imaging.pngimage,SysUtils,Types;
const 
TerrainsTypes = 9;
var
Terrain,Ground,MainBmp : TBitmap;
Img_Ground : TPNGImage;
Img_Build : Array [0..NBuildings]  of TBitmap;
Img_Bases : Array[1..NPlayers] of TPNGImage;
Img_Planes : Array[1..NPlayers] of TBitmap;
Img_Terrain : Array[0..TerrainsTypes] of TPNGImage;
PlanesCols : Array [1..NPlayers] of LongWord = ($0000FF,$FF0000,$00FF00,$00FFFF,$FFFFFF,$000000,$808080);

procedure InitBitmaps;
procedure LoadTerrain;
procedure Render;
procedure RenderBase(area2:PAreab);
procedure GenerateTerrain;
function  SecToPixels(N:Integer):Integer;
function  SecToGround(N:Integer):Integer;
function  CoordToPixels(N:Integer):Integer;
function  PixelsToSec(N:Integer):Integer;
function  PixelsToCoord(N:Integer):Integer;
function  GetType(i,j:Byte):Byte;
function  IsWater(i,j:byte):Boolean;

implementation
procedure InitBitmaps;
var i,j,k:Integer;
begin
  Terrain := TBitMap.Create;
  MainBmp := TBitMap.Create;
  Ground  := TBitMap.Create;
  Terrain.Width  := AreaPixels*LArea;
  Terrain.Height := AreaPixels*LArea;
  Ground.Width  := BasePixels*LBaseArea;
  Ground.Height := BasePixels*LBaseArea;
  for i := 1 to NPlayers do
   begin
     Img_Bases[i] := TPNGImage.Create;
     Img_Bases[i].LoadFromFile('./Images/base'+InttoStr(i)+'.png');
     //Img_Bases[i].CreateAlpha;
     Img_Bases[i].RemoveTransparency;
     Img_Bases[i].TransparentColor :=$FF00FF; //Фиолетовый
     Img_Planes[i] := TBitMap.Create;
     Img_Planes[i].Width := 10;
     Img_Planes[i].Height := 10;
     for j := 0 to 9 do
       for k:= 0 to 9 do
         Img_Planes[i].Canvas.Pixels[j,k] := PlanesCols[i]; //Или же через FillRect;
   end; 
  for  i:=0 to TerrainsTypes do
   begin
    Img_Terrain[i] := TPNGImage.Create;
    Img_Terrain[i].LoadFromFile('./Images/img'+InttoStr(i)+'.png');
   end;
  for i := 0 to NBuildings do
    begin
      Img_Build[i] := TBitMap.Create;
      Img_Build[i].Width := BasePixels;
      Img_Build[i].Height := BasePixels;
      for j := 0 to BasePixels-1 do
         for k:= 0 to BasePixels-1 do
           Img_Build[i].Canvas.Pixels[j,k] := BuildCols[i];
    end;
  Img_Ground:= TPNGImage.Create;
  Img_Ground.LoadFromFile('./Images/base_ground.png');
end;
procedure LoadTerrain;
var i,j,T_Type:Integer;
ARect:TRect;
begin
  for I := 1 to Larea  do  //Устанавливаем флаги баз
    for j := 1 to Larea  do
      begin
         Arect.Left   := SecToPixels(i);
         Arect.Right  := SecToPixels(i+1)-1;
         Arect.Top    := SecToPixels(j);
         Arect.Bottom := SecToPixels(j+1)-1;
         T_Type       := GetType(i,j);
         Terrain.Canvas.StretchDraw(ARect, Img_Terrain[T_Type]);
      end;
  Terrain.Canvas.Pen.Color := ClBlack;
  for i := 0 to Larea-1 do   //Построение решётки 
    begin
      Terrain.Canvas.MoveTo(1,AreaPixels*i);
      Terrain.Canvas.LineTo(AreaPixels*LArea,AreaPixels*i);
      Terrain.Canvas.MoveTo(AreaPixels*i,1);
      Terrain.Canvas.LineTo(AreaPixels*i,AreaPixels*LArea);
    end;
  for I := 1 to 4 do  //Зарисовываем территорию подложки
    for j := 1 to 4 do
      begin
         Arect.Left   := 250*(i-1);
         Arect.Right  := 250*(i);
         Arect.Top    := 250*(j-1);
         Arect.Bottom := 250*(j);
         Ground.Canvas.StretchDraw(ARect, Img_Ground);
      end;
end;

procedure Render;
var
i,j,k:Integer;
ARect: TRect;
begin
  MainBmp.Assign(Terrain);  //Подкладываем территорию
  for I := 1 to Larea  do  //Устанавливаем флаги баз
    for j := 1 to Larea  do
      if (Area[i,j].Plm>0) and ((area[i,j].Timerasv[1]>TimeToBase) or CheatMode) then
        begin
          Arect.Left   := SecToPixels(i);
          Arect.Right  := SecToPixels(i+1)-1;
          Arect.Top    := SecToPixels(j);
          Arect.Bottom := SecToPixels(j+1)-1;
          MainBmp.Canvas.StretchDraw(ARect, Img_Bases[Area[i,j].Plm]);
        end;
  for I := 0 to Length(Samolets)-1 do
    if (Samolets[i]<>nil) and ((Samolets[i].plm<2) or (CheatMode)) then
      begin
        j :=  CoordToPixels(Samolets[i].CoordX);
        k :=  CoordToPixels(Samolets[i].CoordY);
        MainBmp.Canvas.Draw(j,k, Img_Planes[Samolets[i].plm]);
      end;
end;

procedure RenderBase;
var
i,j,k:Integer;
begin
  MainBmp.Assign(Ground);
   for I := 1 to LBasearea  do  //Устанавливаем флаги баз
    for j := 1 to LBasearea  do
      if (Area2[i,j].plm>0) then
        if (Area2[i,j].plm<=NBuildings) then MainBmp.Canvas.Draw(SecToGround(i),SecToGround(j), Img_Build[Area2[i,j].Plm])
                                        else MainBmp.Canvas.Draw(SecToGround(i),SecToGround(j), Img_Build[0]); //Стоящееся-серым
end;

function  SecToPixels;
begin
  result := AreaPixels*(N-1)+1;
  if result<1 then result := 1;
end;

function  SecToGround;
begin
  result := BasePixels*(N-1);
  if result<0 then result := 0;
end;


function CoordToPixels;
begin
  result := Round(N/SectorDlinna*50)-5;
  if result<1 then result := 1;
  if result+10>AreaPixels*LArea then result := AreaPixels*LArea -10;
end;

function PixelsToSec;
begin
  result := (N-1) div AreaPixels +1;
end;
// By Stalker1917  LGPL 3.0
function PixelsToCoord;
begin
  result := Round(N*SectorDlinna/AreaPixels);
end;


function GetType;
begin
  if (i<1) or (j<1) or (i>Larea) or (j>Larea) then Result := 0; //За пределами всё полная суша.
  if IsWater(i,j) then result := 9
  else
    begin
      result := 0;
      if (j>1) and (IsWater(i,j-1)) then result := 2;
      if (i<LArea) and (IsWater(i+1,j)) then result := 4;
      if (j<LArea) and (IsWater(i,j+1)) then result := 6;
      if (i>1) and (IsWater(i-1,j)) then result := 8;
      if result>0 then exit;//Горизонталь и вертикаль имеет больший приоритет

      if (j>1) and (i>1) and  (IsWater(i-1,j-1)) then result := 1;
      if (i<LArea) and (j>1) and (IsWater(i+1,j-1)) then result := 3;
      if (i<LArea) and (j<LArea) and (IsWater(i+1,j+1)) then result := 5;
      if (j<LArea) and (i>1) and (IsWater(i-1,j+1)) then result := 7;
    end;

end;

procedure GenerateTerrain;
var i,j:Integer;
begin
for J := 1 to LArea do
  for i := 1 to LArea do
    case GetType(i-1,j) of
      0:
       // begin
          if (GetType(i,j-1)=0) and (GetType(i-1,j-1)=0) and (GetType(i+1,j-1)=0)  then
            if Random(100)<40 then  area[i,j].clr := $FFFF00;
       // end;
      //2: if IsWater(i,j-1) then  area[i,j].clr := $FFFF00; //2- всегда сушу ставим
      3: if Random(100)<40 then  area[i,j].clr := $FFFF00;  //можно как сушу так и воду
      9: if IsWater(i,j-1) then  area[i,j].clr := $FFFF00
         else
           if (GetType(i,j-1)=7) and (GetType(i+1,j-1)<>3) and (GetType(i+1,j-1)<>4) then //0 невозможен
             if Random(100)<40 then  area[i,j].clr := $FFFF00;
    end;

end;

function  IsWater;
begin
  if (i<1) or (j<1) or (i>Larea) or (j>Larea) then Result := False
  else Result :=  (area[i,j].clr=$FFFF00);
end;



//Генерация  
//Только если GetType даёт 0, то можно воду.    
begin
end.