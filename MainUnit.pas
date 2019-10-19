unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, Grids, DBGrids, ExtCtrls, ComCtrls, StdCtrls, IniFiles, Gauges;

type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Connected: TRadioButton;
    dll: TCheckBox;
    DBGrid1: TDBGrid;
    SpeedButton7: TSpeedButton;
    Button1: TButton;
    Gauge1: TGauge;
    function DajDLL(kom:TStringList):Integer;
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButtonClick(Sender: TObject);
    function CurrentUserName:String;
    function CurrentComputerName:String;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  MyIni: TIniFile;
  izmjena, Godina, lokalni_server, skladiste, Baza: String;

implementation

uses DataUnit, PojamUnit;

{$R *.DFM}

function openport:Integer ; stdcall; external 'TL2B32.DLL';
function closeport:Integer ; stdcall; external 'TL2B32.DLL';
function transmitstring(data:Pchar):Integer; stdcall; external 'TL2B32.DLL';
function receivestring(data:Pchar):Integer; stdcall; external 'TL2B32.DLL';

function TMainForm.DajDLL(kom:TStringList):Integer;
var rez,err,i: Integer;
    data:    String;
    log:     TStringList;
Begin
     log:=TStringList.Create;
     err:=OpenPort;
     if err<>0 then
     begin
        Result:=-1;
        ShowMessage('Greška kod otvaranja porta: '+IntToStr(err));
     end else
     begin
        Connected.Checked:=True;
        i:=0;
        Panel1.Height:=90;
        Gauge1.Progress:=0;
        Gauge1.MaxValue:=kom.Count-1;
        While i<kom.Count-1 do
        Begin
             data:=kom[i];
             i:=i+1;
             Gauge1.AddProgress(1);
             data:=data+kom[i];
             rez:=transmitstring(PChar(data));
             if rez < 0 then
             Begin
                 log.Add('Greška kod slanja komandi: '+IntToStr(rez)+' na PLU '+Copy(data,18,4));
                 Result:=-1;
             end else Result:=0;
             i:=i+1;
             Gauge1.AddProgress(1);
        end;
        err:=ClosePort;
        if err<>0 then
        Begin
           ShowMessage('Greška kod zatvaranja porta: '+IntToStr(err));
           Result:=-2;
        end else Connected.Checked:=False;
        if log.Count > 0 then
        begin
             ShowMessage('Bilo je grešaka u transferu. Kreiran LOG file.');
             log.SaveToFile('error.log');
             log.Free;
        end;
        Panel1.Height:=65;
     end;
end;

function TMainForm.CurrentUserName:String;
var
  u: array[0..127] of Char;
  sz:DWord;
begin
  sz:=SizeOf(u);
  GetUserName(u,sz);
  Result:=u;
end;

function TMainForm.CurrentComputerName:String;
var
  u: array[0..127] of Char;
  sz:DWord;
begin
  sz:=SizeOf(u);
  GetComputerName(u,sz);
  Result:=u;
end;

procedure TMainForm.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
     if Key in ['A'..'Z','a'..'z','0'..'9','š','ð','è','æ','ž','Š','Ð','Ž','Æ','È','%'] then
     begin
          PojamForm.Edit1.Text := Key;
          PojamForm.Edit1.SelStart := 1;
          PojamForm.ShowModal;
          if PojamForm.ModRes then
          begin
               Data.Daj_Trazi( DBGrid1.Fields[DBGrid1.SelectedIndex].FieldName, PojamForm.Edit1.Text);
          end;
     end;
end;

procedure TMainForm.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if Key = 27 then MainForm.Close
     else if Key = VK_INSERT then Data.Action_Insert
     else if Key = 13 then Data.Action_Edit
     else if Key = VK_DELETE then Data.Action_Delete
     else if Key = VK_F8 then Data.Action_Print;
end;

procedure TMainForm.SpeedButtonClick(Sender: TObject);
begin
     if Sender = SpeedButton1 then Data.Action_Insert
     else if Sender = SpeedButton2 then Data.Action_Edit
     else if Sender = SpeedButton3 then Data.Action_Delete
     else if Sender = SpeedButton4 then Data.Action_Print
     else if Sender = SpeedButton5 then Data.Action_SviPLU
     else if Sender = SpeedButton6 then Data.Azuriraj
     else if Sender = SpeedButton7 then Data.Daj_Izmjene;
             //ShowMessage(IntToStr(DajDLL(Data.Upis)));
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
     MyIni := TiniFile.Create(GetCurrentDir + '\Config.ini');
     lokalni_server := MyIni.ReadString('Vaga','Lokalni server','N/A');
     godina := MyIni.ReadString('Vaga','Godina','N/A');
     skladiste := MyIni.ReadString('Vaga','Skladište','N/A');
     baza := MyIni.ReadString('Vaga','Baza','N/A');
     izmjena := MyIni.ReadString('Vaga','Izmjena','N/A');
     MyIni.Free;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
     MyIni := TiniFile.Create(GetCurrentDir + '\Config.ini');
     MyIni.WriteString('Vaga','Izmjena',izmjena);
     MyIni.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
     ShowMessage(IntToStr(DajDLL(Data.Upis)));
end;

end.
