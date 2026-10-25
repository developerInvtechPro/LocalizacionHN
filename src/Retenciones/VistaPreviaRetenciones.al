namespace INVTECH.Honduras;
using Microsoft.Finance.GeneralLedger.Preview;

codeunit 50104 "HN Retention Preview"
{
    TableNo = "HN Retention Header";
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        Management: Codeunit "HN Retention Management";
        PostingPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        Management.Post(Rec);
        PostingPreview.ThrowError();
    end;

    procedure Preview(var Header: Record "HN Retention Header")
    var
        Subscriber: Codeunit "HN Retention Preview";
        PostingPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(Subscriber);
        PostingPreview.Preview(Subscriber, Header);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        Header: Record "HN Retention Header";
        Runner: Codeunit "HN Retention Preview";
    begin
        Runner := Subscriber;
        Header.Copy(RecVar);
        Result := Runner.Run(Header);
    end;
}
