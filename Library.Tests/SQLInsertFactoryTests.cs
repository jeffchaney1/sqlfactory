using Library.SQLFactory;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Library.Tests
{
    [TestClass]
    class SQLInsertFactoryTests
    {
        [TestMethod]
        public void TestSQLInsertFactory()
        {
            SQLInsertFactory INSERT = new SQLInsertFactory();
            INSERT.Columns.Add("FirstName", "Test");
            INSERT.Columns.Add("LastName", "Bedford");

            INSERT.IntoTable.TableName = "USERS";
            AssertSQL.AreEqual("INSERT INTO [USERS]"
                +"(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT.IntoTable.TableAlias = "ALIAS";
            AssertSQL.AreEqual("INSERT INTO [USERS] [ALIAS]"
                + "(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT.IntoTable.TableSchema = "dbo";
            AssertSQL.AreEqual("INSERT INTO [dbo].[USERS] [ALIAS]"
                + "(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT.IntoTable.DatabaseName = "database";
            AssertSQL.AreEqual("INSERT INTO [database].[dbo].[USERS] [ALIAS]"
                + "(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT.IntoTable.ServerName = "Server";
            AssertSQL.AreEqual("INSERT INTO [Server].[database].[dbo].[USERS] [ALIAS]"
                + "(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT.IntoTable.AddDelimiters = false;
            AssertSQL.AreEqual("INSERT INTO Server.database.dbo.USERS ALIAS"
                + "(FirstName, LastName) VALUES ('Test', 'Bedford')", INSERT.BuildSQL());

            INSERT = new SQLInsertFactory();
            INSERT.IntoTable.TableName = "#USERS";
            INSERT.Columns.AddColumns("FNAME", "LNAME");

            INSERT.FromQuery.FromTable.TableName = "dbo.Users";
            INSERT.FromQuery.Where.Add("LastName NOT LIKE 'Samuel%'");
            INSERT.FromQuery.Columns.Add("FirstName", "LastName");

            AssertSQL.AreEqual("INSERT INTO #USERS (FNAME, LNAME) " +
                "SELECT FirstName, LastName FROM dbo.Users WHERE LastName NOT LIKE 'Samuel%'"
                , INSERT.BuildSQL());

        }
    }
}
