-- 1. Create database if missing
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'MyProductivityAppDb')
    CREATE DATABASE MyProductivityAppDb;
GO

USE MyProductivityAppDb;
GO

--------------------------------------------------------------------------------
-- 2. Users
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;
CREATE TABLE dbo.Users (
    UserId       UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    Email        NVARCHAR(256)     NOT NULL UNIQUE,
    PasswordHash NVARCHAR(512)     NOT NULL,
    FullName     NVARCHAR(200)     NULL,
    CreatedAt    DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

--------------------------------------------------------------------------------
-- 3. Events (Calendar / Reminders)
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Events','U') IS NOT NULL DROP TABLE dbo.Events;
CREATE TABLE dbo.Events (
    EventId     UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId      UNIQUEIDENTIFIER NOT NULL
                  REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Title       NVARCHAR(200)    NOT NULL,
    Description NVARCHAR(MAX)    NULL,
    StartTime   DATETIME2        NOT NULL,
    EndTime     DATETIME2        NULL,
    IsAllDay    BIT              NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

--------------------------------------------------------------------------------
-- 4. Notes & Tags
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Notes','U') IS NOT NULL DROP TABLE dbo.Notes;
CREATE TABLE dbo.Notes (
    NoteId     UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId     UNIQUEIDENTIFIER NOT NULL
                  REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Title      NVARCHAR(200)    NULL,
    Content    NVARCHAR(MAX)    NOT NULL,
    CreatedAt  DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt  DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('dbo.Tags','U') IS NOT NULL DROP TABLE dbo.Tags;
CREATE TABLE dbo.Tags (
    TagId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    Name  NVARCHAR(100)     NOT NULL UNIQUE
);
GO

IF OBJECT_ID('dbo.NoteTags','U') IS NOT NULL DROP TABLE dbo.NoteTags;
CREATE TABLE dbo.NoteTags (
    NoteId UNIQUEIDENTIFIER NOT NULL
           REFERENCES dbo.Notes(NoteId) ON DELETE CASCADE,
    TagId  UNIQUEIDENTIFIER NOT NULL
           REFERENCES dbo.Tags(TagId) ON DELETE CASCADE,
    PRIMARY KEY (NoteId, TagId)
);
GO

--------------------------------------------------------------------------------
-- 5. Projects, Tasks & Collaboration
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Projects','U') IS NOT NULL DROP TABLE dbo.Projects;
CREATE TABLE dbo.Projects (
    ProjectId   UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId      UNIQUEIDENTIFIER NOT NULL
                  REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Name        NVARCHAR(200)     NOT NULL,
    Description NVARCHAR(MAX)     NULL,
    RepoUrl     NVARCHAR(500)     NULL,  -- link to source/repo/docs
    CreatedAt   DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('dbo.Tasks','U') IS NOT NULL DROP TABLE dbo.Tasks;
CREATE TABLE dbo.Tasks (
    TaskId      UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    ProjectId   UNIQUEIDENTIFIER NOT NULL
                  REFERENCES dbo.Projects(ProjectId) ON DELETE CASCADE,
    Title       NVARCHAR(200)     NOT NULL,
    Description NVARCHAR(MAX)     NULL,
    Status      NVARCHAR(50)      NOT NULL DEFAULT 'New',
    DueDate     DATETIME2         NULL,
    CreatedAt   DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

--------------------------------------------------------------------------------
-- 6. Credential Vault
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Credentials','U') IS NOT NULL DROP TABLE dbo.Credentials;
CREATE TABLE dbo.Credentials (
    CredentialId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId       UNIQUEIDENTIFIER NOT NULL
                  REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Title        NVARCHAR(200)     NOT NULL,
    Username     NVARCHAR(200)     NOT NULL,
    PasswordEnc  VARBINARY(MAX)    NOT NULL,
    Notes        NVARCHAR(MAX)     NULL,
    CreatedAt    DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt    DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

--------------------------------------------------------------------------------
-- 7. Report & Document Templates
--------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ReportTemplates','U') IS NOT NULL DROP TABLE dbo.ReportTemplates;
CREATE TABLE dbo.ReportTemplates (
    ReportTemplateId UNIQUEIDENTIFIER NOT NULL
                     PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId           UNIQUEIDENTIFIER NOT NULL
                     REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Name             NVARCHAR(200)    NOT NULL,
    Description      NVARCHAR(MAX)    NULL,
    TemplateContent  NVARCHAR(MAX)    NOT NULL,  -- JSON, HTML, etc.
    CreatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('dbo.DocumentTemplates','U') IS NOT NULL DROP TABLE dbo.DocumentTemplates;
CREATE TABLE dbo.DocumentTemplates (
    DocumentTemplateId UNIQUEIDENTIFIER NOT NULL
                       PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
    UserId             UNIQUEIDENTIFIER NOT NULL
                       REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    Name               NVARCHAR(200)    NOT NULL,
    Description        NVARCHAR(MAX)    NULL,
    TemplateFilePath   NVARCHAR(500)    NOT NULL,  -- blob key or URL
    CreatedAt          DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt          DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

--------------------------------------------------------------------------------
-- 8. Indexes
--------------------------------------------------------------------------------
CREATE INDEX IX_Events_UserId         ON dbo.Events(UserId);
CREATE INDEX IX_Notes_UserId          ON dbo.Notes(UserId);
CREATE INDEX IX_Tags_Name             ON dbo.Tags(Name);
CREATE INDEX IX_Projects_UserId       ON dbo.Projects(UserId);
CREATE INDEX IX_Tasks_ProjectId       ON dbo.Tasks(ProjectId);
CREATE INDEX IX_Credentials_UserId    ON dbo.Credentials(UserId);
CREATE INDEX IX_ReportTemplates_UserId ON dbo.ReportTemplates(UserId);
CREATE INDEX IX_DocumentTemplates_UserId ON dbo.DocumentTemplates(UserId);
GO
