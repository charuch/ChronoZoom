namespace Chronozoom.Entities
{
    using System;
    using System.Data.Entity.Migrations;

    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Proc"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores")]
    public partial class ProgressiveLoad_TimelineSubtreeQuerySProc : DbMigration
    {
        public override void Up()
        {
            if (System.Configuration.ConfigurationManager.ConnectionStrings[0].ProviderName.Equals("System.Data.SqlClient"))
            {
                this.Sql(Properties.Resources.TracePathToRoot);
                this.Sql("DROP PROCEDURE TimelineSubtreeQuery");
                this.Sql(Properties.Resources.TimelineSubtreeQuery);
            }
        }

        public override void Down()
        {
            if (System.Configuration.ConfigurationManager.ConnectionStrings[0].ProviderName.Equals("System.Data.SqlClient"))
            {
                this.Sql("DROP PROCEDURE TimelineSubtreeQuery");
            }
        }
    }
}
