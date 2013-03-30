unit uLogOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GnuGettext, uTools, uMain,
  Vcl.Buttons;

type
  TfLogOptions = class(TForm)
    FontDialog1: TFontDialog;
    lblLogFont: TLabel;
    tLogFont: TEdit;
    lblLogFontSize: TLabel;
    bSelect: TButton;
    tLogFontSize: TEdit;
    bSave: TBitBtn;
    bCancel: TBitBtn;
    procedure bSelectClick(Sender: TObject);
    procedure FontDialog1Apply(Sender: TObject; Wnd: HWND);
    procedure FontDialog1Close(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fLogOptions: TfLogOptions;

implementation

{$R *.dfm}

procedure TfLogOptions.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfLogOptions.bSaveClick(Sender: TObject);
begin
  Config.LogSettings.Font := FontDialog1.Font.Name;
  Config.LogSettings.FontSize := FontDialog1.Font.Size;
  fMain.AdjustLogFont(FontDialog1.Font.Name, FontDialog1.Font.Size);
  SaveSettings;
  Close;
end;

procedure TfLogOptions.bSelectClick(Sender: TObject);
begin
  FontDialog1.Execute();
end;

procedure TfLogOptions.FontDialog1Apply(Sender: TObject; Wnd: HWND);
begin
  tLogFont.Text := FontDialog1.Font.Name;
  tLogFontSize.Text := IntToStr(FontDialog1.Font.Size);
end;

procedure TfLogOptions.FontDialog1Close(Sender: TObject);
begin
  tLogFont.Text := FontDialog1.Font.Name;
  tLogFontSize.Text := IntToStr(FontDialog1.Font.Size);
end;

procedure TfLogOptions.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

procedure TfLogOptions.FormShow(Sender: TObject);
begin
  tLogFont.Text := Config.LogSettings.Font;
  tLogFontSize.Text := IntToStr(Config.LogSettings.FontSize);
  FontDialog1.Font.Name := Config.LogSettings.Font;
  FontDialog1.Font.Size := Config.LogSettings.FontSize;
end;

end.
