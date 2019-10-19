unit TransUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TTransForm = class(TForm)
    Timer1: TTimer;
    ListBox1: TListBox;
    Edit1: TEdit;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TransForm: TTransForm;

implementation

{$R *.DFM}

procedure TTransForm.Timer1Timer(Sender: TObject);
var SI1: TStartupInfo;
    PI1: TProcessInformation;
    Prep: TStringList;
    S: String;
    F: TextFile;
begin
     S := '';
     Prep := TStringList.Create;
     try Prep.LoadFromFile( 'f:\plup\z_upit.txt' );
     except
           Timer1.Enabled := True;
           Prep.Free;
           Exit;
     end;
     Edit1.Text := Prep.Strings[0];
     Prep.Clear;
     Prep.Add( '0' ); //Prep.Add( '2' );
     try Prep.SaveToFile( 'f:\plup\z_upit.txt' );
     except
           Timer1.Enabled := True;
           Prep.Free;
           Exit;
     end;
     if Edit1.Text = '2' then
     begin
          Edit1.Text := '0';
          Prep.Clear;
          try Prep.LoadFromFile( 'f:\plup\z_cargo.kom' );
          except
                Timer1.Enabled := True;
                Prep.Free;
                Exit;
          end;
          Prep.SaveToFile( 'c:\program files\birosoft\vaga.kom' );
          Timer1.Enabled := False;
          ZeroMemory( Addr( SI1 ), SizeOf( SI1 ) );
          SI1.cb:=SizeOf( SI1 );
          try
             CreateProcess( nil, PChar( 'f:\plup\z_trans.bat' ), nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil, SI1, PI1 );
             case WaitForSingleObject( PI1.hProcess, INFINITE ) of
                  WAIT_FAILED : S := FormatDateTime( 'dd.MM.yyyy hh:mm:ss', Now ) + '    wait_failed - ERROR';
                  WAIT_ABANDONED : S := FormatDateTime( 'dd.MM.yyyy hh:mm:ss', Now ) + '    wait_abandoned - OK';
                  WAIT_OBJECT_0 : S := FormatDateTime( 'dd.MM.yyyy hh:mm:ss', Now ) + '    wait_object_0 - OK';
                  WAIT_TIMEOUT : S := FormatDateTime( 'dd.MM.yyyy hh:mm:ss', Now ) + '    wait_timeout - OK';
             end;
          except
                Timer1.Enabled := True;
                Prep.Free;
                Exit;
          end;
          if S <> '' then
          begin
               AssignFile( F, 'c:\program files\birosoft\memo.log' );
               Append( F );
               Writeln( F, S );
               CloseFile( F );
               ListBox1.Items.Add( S );
               Timer1.Enabled := True;
          end;
     end;
     Prep.Free;
     if ListBox1.Items.Count > 19 then ListBox1.Clear;
end;

end.
