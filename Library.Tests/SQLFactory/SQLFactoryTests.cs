using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Library.SQLFactory;

namespace Library.Tests.SQLFactory
{
    [TestClass]
    public class SQLFactoryTests
    {
        static String STD_INDENT = Library.SQLFactory.SQLFactory.STD_INDENT;

        [TestMethod]
        public void TestColumnInfo()
        {
            String columnInfo = "[table].[column] alias";
            String tableAlias;
            String columnExpression;
            String columnAlias;

            Library.SQLFactory.SQLFactory.ParseColumnInfo(columnInfo, out tableAlias, out columnExpression, out columnAlias);

            Assert.AreEqual("alias", columnAlias);
            Assert.AreEqual("[column]", columnExpression);
            Assert.AreEqual("[table]", tableAlias);

        }

        //public static String PrintableCharacters = "[\\040-\\177]";
        //public static String NonPrintableCharacters = PrintableCharacters.Insert(1, "^");
        //public static String IdentifierBodyCharacters = "[0-9A-Za-z_]";
        //public static String NotIdentifierBodyCharacters = IdentifierBodyCharacters.Insert(1, "^");

        //public static void ParseColumnInfo(String columnInfo, out String tableAlias, out String columnExpression, out String columnAlias)
        //{
        //    tableAlias = "";
        //    columnExpression = "";
        //    columnAlias = "";

        //    String cleaned = Regex.Replace(columnInfo, "[^\\040-\\177]", "");
        //    int p=columnInfo.Length;
        //    columnAlias = ParsePrev(ref p, cleaned, " ", "\"", "[]");
        //    if (p > 0) {
        //        columnAlias = RemoveBrackets("[", columnAlias, "]");

        //        if (columnAlias == columnAlias.Replace(NotIdentifierBodyCharacters, "")) {
        //            cleaned = cleaned.Substring(0, p+1);
        //            String tmp = ParsePrev(ref p, cleaned, " ", "\"", "");
        //            if (tmp.Equals("AS", StringComparison.OrdinalIgnoreCase)) 
        //                cleaned = cleaned.Substring(1, p);
        //        }
        //        else {
        //          columnAlias = "";
        //        }
        //    }
        //    else /*there was no alias delimited by a space*/ {
        //        columnAlias = "";
        //    }

        //    p = 0;
        //    columnExpression = ParseNext(ref p, cleaned, ".", "\"'", "[]()");
        //    tableAlias = "";
        //    while (p < cleaned.Length) {
        //        tableAlias = tableAlias + columnExpression;
        //        columnExpression = ParseNext(ref p, cleaned, ".", "\"'", "[]()");
        //    }
        //}

        [TestMethod]
        public void TestSQLFactoryFromTable()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "USERS";
            Assert.AreEqual("SELECT * FROM [USERS]", SELECT.BuildSQL());

            SELECT.FromTable.TableAlias = "ALIAS";
            Assert.AreEqual("SELECT * FROM [USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.TableSchema = "dbo";
            Assert.AreEqual("SELECT * FROM [dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.DatabaseName = "database";
            Assert.AreEqual("SELECT * FROM [database].[dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.ServerName = "Server";
            Assert.AreEqual("SELECT * FROM [Server].[database].[dbo].[USERS] [ALIAS]", SELECT.BuildSQL());

            SELECT.FromTable.AddDelimiters = false;
            Assert.AreEqual("SELECT * FROM Server.database.dbo.USERS ALIAS", SELECT.BuildSQL());

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "dbo.USERS";
            Assert.AreEqual("USERS", SELECT.FromTable.TableName);
            Assert.AreEqual("USERS", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("", SELECT.FromTable.ServerName);

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "dbo.[USERS] alias";
            Assert.AreEqual("[USERS]", SELECT.FromTable.TableName);
            Assert.AreEqual("alias", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("", SELECT.FromTable.ServerName);

            Assert.AreEqual(false, SELECT.FromTable.AddDelimiters);
            Assert.AreEqual("SELECT * FROM dbo.[USERS] alias", SELECT.BuildSQL());

            SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "server.Database.dbo.USERS alias";
            Assert.AreEqual("USERS", SELECT.FromTable.TableName);
            Assert.AreEqual("alias", SELECT.FromTable.TableAlias);
            Assert.AreEqual("dbo", SELECT.FromTable.TableSchema);
            Assert.AreEqual("Database", SELECT.FromTable.DatabaseName);
            Assert.AreEqual("server", SELECT.FromTable.ServerName);

        }

        [TestMethod]
        public void TestColumns()
        {
            SQLSelectFactory SELECT = new SQLSelectFactory();
            SELECT.FromTable.TableName = "table";
            SelectColumn col = SELECT.Columns.Add("COL1");
            Assert.AreEqual("COL1", col.ColumnName);
            Assert.AreEqual("COL1", col.ColumnAlias);
            Assert.AreEqual("SELECT [COL1] \nFROM [table]", SELECT.BuildSQL());

            col = SELECT.Columns.Add("COL2 COL2_ALIAS");
            Assert.AreEqual("COL2", col.ColumnName);
            Assert.AreEqual("COL2_ALIAS", col.ColumnAlias);
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS] \nFROM [table]", SELECT.BuildSQL());

            col = SELECT.Columns.Add("table.COL3 COL3_ALIAS");
            Assert.AreEqual("COL3", col.ColumnName);
            Assert.AreEqual("COL3_ALIAS", col.ColumnAlias);
            Assert.AreEqual("table", col.TableName);
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], [table].[COL3] [COL3_ALIAS] \nFROM [table]", SELECT.BuildSQL());

            col.AddDelimiters = false;
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], table.COL3 COL3_ALIAS \nFROM [table]", SELECT.BuildSQL());

            SELECT.Columns.Add(new String[] {"COL4", "COL5 COL5_ALIAS", "table.COL6 COL6_ALIAS"});
            Assert.AreEqual("SELECT [COL1], [COL2] [COL2_ALIAS], table.COL3 COL3_ALIAS, COL4 \n" + STD_INDENT + 
                            "[COL5] [COL5_ALIAS], [table].[COL6] [COL6_ALIAS] \n" +
                            "FROM [table]"
                            , SELECT.BuildSQL());
            

        }
    }
}
