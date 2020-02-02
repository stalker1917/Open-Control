// By Stalker1917  LGPL 3.0
unit Unit2;

interface
{$A-}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,TimeManager,AiManager,AreaManager,ControlConsts,OCGraph;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  f : TBFile;
implementation
uses Unit1;

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var i,j,k,m,l: Integer;
Ls : SmallInt;
begin
 if OpenDialog1.Execute then
   begin
     for i := 1 to 15 do
      for j := 1 to 15 do
        if area[i,j].areab<>Nil then Dispose(area[i,j].areab);
     AssignFile(f,OpenDialog1.FileName);
     Reset(f);
     BlockRead(f,CurrSaveVersion,2);
     if (CurrSaveVersion<1) or (CurrSaveVersion>SaveVersion) then      //Версия файла не совместима с контролем версий
       begin
         CurrSaveVersion := 0;
         Seek(F,0);
       end;
     BlockRead(f,TimeStamp,8);
     BlockRead(f,OldStamp,8);
     //BlockRead(f,Dengi,8);
     //i := Length(Samolets);
     BlockRead(f,Ls,2);
     SetLength(Samolets,Ls);
     Okno := 0;
     OldStamp := TimeStamp;
     CheatMode := False;
    //--- Cмотреть документацию

     for I := 0 to Ls - 1 do
       begin
         New(Samolets[i]);
         BlockRead(f,Samolets[i]^,Sizeof(TSamolet));
         if Samolets[i].plm=255 then
           Samolets[i] := nil;
       end;
     BlockRead(f,area[1,1],LArea*LArea*Sizeof(TField));
     BlockRead(f,Plems,7*4);
     for I := 1 to NPlayers do BankofTrigers[i].Load(F);
     LoadTerrain; //Перестроить карту местности.
     CloseFile(F);

   end;
end;

procedure TForm2.Button2Click(Sender: TObject);
var i,j,k,m,l: Integer;
A: SmallInt;
Sm : TSamolet;
begin
 if SaveDialog1.Execute then
   begin
     AssignFile(f,Savedialog1.FileName);
     Rewrite(f);
     BlockWrite(f,SaveVersion,2); //Записать версию сохранения.
     BlockWrite(f,TimeStamp,8);
     BlockWrite(f,OldStamp,8);
    // BlockWrite(f,Dengi,8);
     A := Length(Samolets);
     BlockWrite(f,A,2);
     Sm.plm := 255;
       //- Cмотреть документацию
     for I := 0 to Length(Samolets) - 1 do if Samolets[i]<>nil then BlockWrite(f,Samolets[i]^,Sizeof(TSamolet))
                                                               else BlockWrite(f,Sm,Sizeof(TSamolet));
     BlockWrite(f,area[1,1],LArea *LArea*Sizeof(TField));
     BlockWrite(f,Plems,7*4);
     for I := 1 to NPlayers do BankofTrigers[i].Save(F);
     CloseFile(F);
   end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  F2Otkl := 0;
  Close;

end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  F2Otkl := 1;
  Close;

end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Left := Screen.Width*3 div 8;
  Top  := Screen.Height*3 div 8;
end;

end.
