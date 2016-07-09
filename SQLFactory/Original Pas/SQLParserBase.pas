{******************************************************************************
  Class to parse SQL statements from a string into a SQLFactory
  @author Jeff Chaney
  @author Guardian Industries, Inc., Auburn Hills, MI
  @author Last Changed By: $Author: jchaney $ $Date: 2010/01/29 19:10:56 $
  @group --TBD
  @see SQLFactory
  @version $Id: SQLParserBase.pas,v 1.5 2010/01/29 19:10:56 jchaney Exp $
  @version
******************************************************************************}
unit SQLParserBase;

interface

uses
  gaBasicSQLParser, gaAdvancedSQLParser, gaParserVisitor,
  gaDeleteStm, gaInsertStm, gaSelectStm, gaUpdateStm,
  gaSQLParserHelperClasses, gaSQLFieldRefParsers, gaSQLSelectFieldParsers,
  gaSQLExpressionParsers, gaSQLTableRefParsers;


type
  TBaseSQLFactoryVisitor = class(TgaCustomParserVisitor)
    procedure VisitCustomSQLStatement(Instance: TgaCustomSQLStatement); override;
    procedure VisitDeleteSQLStatement(Instance: TgaDeleteSQLStatement); override;
    procedure VisitHavingClause(Instance: TgaHavingClause); override;
    procedure VisitInsertSQLStatement(Instance: TgaInsertSQLStatement); override;
    procedure VisitJoinClause(Instance: TgaJoinClause); override;
    procedure VisitJoinClauseList(Instance: TgaJoinClauseList); override;
    procedure VisitJoinOnPredicate(Instance: TgaJoinOnPredicate); override;
    procedure VisitListOfSQLTokenLists(Instance: TgaListOfSQLTokenLists); override;
    procedure VisitNoSQLStatement(Instance: TgaNoSQLStatement); override;
    procedure VisitSecondaryFieldReference(Instance: TgaSecondaryFieldReference); override;
    procedure VisitSelectSQLStatement(Instance: TgaSelectSQLStatement); override;
    procedure VisitSQLDataReference(Instance: TgaSQLDataReference); override;
    procedure VisitSQLExpression(Instance: TgaSQLExpression); override;
    procedure VisitSQLExpressionBase(Instance: TgaSQLExpressionBase); override;
    procedure VisitSQLExpressionConstant(Instance: TgaSQLExpressionConstant); override;
    procedure VisitSQLExpressionFunction(Instance: TgaSQLExpressionFunction);override;
    procedure VisitSQLExpressionList(Instance: TgaSQLExpressionList); override;
    procedure VisitSQLExpressionOperator(Instance: TgaSQLExpressionOperator); override;
    procedure VisitSQLExpressionPart(Instance: TgaSQLExpressionPart); override;
    procedure VisitSQLExpressionPartBuilder(Instance: TgaSQLExpressionPartBuilder); override;
    procedure VisitSQLExpressionSubselect(Instance: TgaSQLExpressionSubselect); override;
    procedure VisitSQLFieldList(Instance: TgaSQLFieldList); override;
    procedure VisitSQLFieldReference(Instance: TgaSQLFieldReference); override;
    procedure VisitSQLFunctionParamsList(Instance: TgaSQLFunctionParamsList); override;
    procedure VisitSQLGroupByList(Instance: TgaSQLGroupByList); override;
    procedure VisitSQLGroupByReference(Instance: TgaSQLGroupByReference); override;
    procedure VisitSQLMultipartExpression(Instance: TgaSQLMultipartExpression); override;
    procedure VisitSQLOrderByList(Instance: TgaSQLOrderByList); override;
    procedure VisitSQLOrderByReference(Instance: TgaSQLOrderByReference); override;
    procedure VisitSQLSelectExpression(Instance: TgaSQLSelectExpression); override;
    procedure VisitSQLSelectField(Instance: TgaSQLSelectField); override;
    procedure VisitSQLSelectFieldList(Instance: TgaSQLSelectFieldList); override;
    procedure VisitSQLSelectReference(Instance: TgaSQLSelectReference); override;
    procedure VisitSQLStatementPart(Instance: TgaSQLStatementPart); override;
    procedure VisitSQLStatementPartList(Instance: TgaSQLStatementPartList); override;
    procedure VisitSQLStoredProcReference(Instance: TgaSQLStoredProcReference); override;
    procedure VisitSQLSubExpression(Instance: TgaSQLSubExpression); override;
    procedure VisitSQLTable(Instance: TgaSQLTable); override;
    procedure VisitSQLTableList(Instance: TgaSQLTableList); override;
    procedure VisitSQLTableReference(Instance: TgaSQLTableReference); override;
    procedure VisitSQLTokenHolderList(Instance: TgaSQLTokenHolderList); override;
    procedure VisitSQLTokenList(Instance: TgaSQLTokenList); override;
    procedure VisitSQLUnrecognizedExpression(Instance: TgaSQLUnrecognizedExpression); override;
    procedure VisitSQLWhereExpression(Instance: TgaSQLWhereExpression); override;
    procedure VisitUnkownSQLStatement(Instance: TgaUnkownSQLStatement); override;
    procedure VisitUpdateSQLStatement(Instance: TgaUpdateSQLStatement); override;
  public
    procedure VisitWith(List : TgaSQLTokenList; Visitor : TgaCustomParserVisitor); overload;
    procedure VisitWith(List : TgaListOfSQLTokenLists; Visitor : TgaCustomParserVisitor); overload;
    function Clean(str : String) : String;
  end;



implementation

uses UnitVersion,   CommonObjLib;


{ TBaseSQLFactoryVisitor }



procedure TBaseSQLFactoryVisitor.VisitWith(List: TgaSQLTokenList;
  Visitor: TgaCustomParserVisitor);
begin
  try
    List.AcceptParserVisitor(Visitor);
  finally
    SafeFree(Visitor);
  end;
end;

procedure TBaseSQLFactoryVisitor.VisitWith(List : TgaListOfSQLTokenLists; Visitor : TgaCustomParserVisitor);
begin
  try
    List.AcceptParserVisitor(Visitor);
  finally
    SafeFree(Visitor);
  end;
end;

function TBaseSQLFactoryVisitor.Clean(str: String): String;
Var
  s, d : Integer;
begin
  SetLength(Result, Length(str));
  d := 0;
  for s := 1 to Length(Str) do
    if (Str[s] >= ' ') then begin
      inc(d);
      Result[d] := Str[s];
    end;

  SetLength(result, d);
end;

procedure TBaseSQLFactoryVisitor.VisitCustomSQLStatement(Instance: TgaCustomSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitDeleteSQLStatement(Instance: TgaDeleteSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitHavingClause(Instance: TgaHavingClause);
begin end;

procedure TBaseSQLFactoryVisitor.VisitInsertSQLStatement( Instance: TgaInsertSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitJoinClause(Instance: TgaJoinClause);
begin end;

procedure TBaseSQLFactoryVisitor.VisitJoinClauseList( Instance: TgaJoinClauseList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitJoinOnPredicate(Instance: TgaJoinOnPredicate);
begin end;

procedure TBaseSQLFactoryVisitor.VisitListOfSQLTokenLists(Instance: TgaListOfSQLTokenLists);
begin
  Instance.First;
  While not Instance.Eof do begin
    Instance.CurrentItem.AcceptParserVisitor(Self);
    Instance.Next;
  end;
end;

procedure TBaseSQLFactoryVisitor.VisitNoSQLStatement(Instance: TgaNoSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSecondaryFieldReference(Instance: TgaSecondaryFieldReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSelectSQLStatement(Instance: TgaSelectSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLDataReference(Instance: TgaSQLDataReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpression(Instance: TgaSQLExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionBase(Instance: TgaSQLExpressionBase);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionConstant(Instance: TgaSQLExpressionConstant);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionFunction(Instance: TgaSQLExpressionFunction);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionList(Instance: TgaSQLExpressionList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionOperator(Instance: TgaSQLExpressionOperator);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionPart(Instance: TgaSQLExpressionPart);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionPartBuilder(Instance: TgaSQLExpressionPartBuilder);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLExpressionSubselect(Instance: TgaSQLExpressionSubselect);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLFieldList(Instance: TgaSQLFieldList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLFieldReference(Instance: TgaSQLFieldReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLFunctionParamsList(Instance: TgaSQLFunctionParamsList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLGroupByList(Instance: TgaSQLGroupByList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLGroupByReference(Instance: TgaSQLGroupByReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLMultipartExpression(Instance: TgaSQLMultipartExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLOrderByList(Instance: TgaSQLOrderByList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLOrderByReference(Instance: TgaSQLOrderByReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLSelectExpression(Instance: TgaSQLSelectExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLSelectField(Instance: TgaSQLSelectField);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLSelectFieldList(Instance: TgaSQLSelectFieldList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLSelectReference(Instance: TgaSQLSelectReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLStatementPart(Instance: TgaSQLStatementPart);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLStatementPartList(Instance: TgaSQLStatementPartList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLStoredProcReference(Instance: TgaSQLStoredProcReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLSubExpression(Instance: TgaSQLSubExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLTable(Instance: TgaSQLTable);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLTableList(Instance: TgaSQLTableList);
begin
  VisitListOfSQLTokenLists(Instance);
end;

procedure TBaseSQLFactoryVisitor.VisitSQLTableReference(Instance: TgaSQLTableReference);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLTokenHolderList(Instance: TgaSQLTokenHolderList);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLTokenList(Instance: TgaSQLTokenList);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLUnrecognizedExpression(Instance: TgaSQLUnrecognizedExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitSQLWhereExpression(Instance: TgaSQLWhereExpression);
begin end;

procedure TBaseSQLFactoryVisitor.VisitUnkownSQLStatement(Instance: TgaUnkownSQLStatement);
begin end;

procedure TBaseSQLFactoryVisitor.VisitUpdateSQLStatement(Instance: TgaUpdateSQLStatement);
begin end;

initialization
{$IFNDEF NOUNITVERSION}
  RegisterUnit('$Source: /Procurement2/shared/SQLParserBase.pas,v $', '$Revision: 1.5 $', '$Date: 2010/01/29 19:10:56 $');
{$ENDIF}
end.

