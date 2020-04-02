WITH cteDeletedDF as
(
SELECT top (@DFBatchSize)
		df.UserFileId,
		@vfId as VirtualFolderId,
		@vfOwnerId as OwnerId,
		df.UserFileVersionId,
		df.FileId,
		df.[Length],
		df.EffectiveDateRemovedUtc as lastDeleteDate,
		@vfFolderId as FolderId
 FROM dbo.vwUserFileInActive df with(nolock)
  WHERE df.[FolderId] = @vfFolderId
	AND df.EffectiveDateRemovedUtc < @maxDFKeepDate
),
cteDeletedDFMatchedRules
as
(
SELECT ROW_NUMBER() over(partition by DF.UserFileId order by T.Priority) rn,
		DATEADD(YEAR, -t.DeletedFileYears,
				DATEADD(MONTH, -t.DeletedFileMonths,
						DATEADD(DAY, -t.DeletedFileDays , @keepDeletedFromDate))) customRuleKeepDate,
		T.DeletedFileDays as customDeletedDays,
		T.DeletedFileMonths as customDeletedMonths,
		T.DeletedFileYears as customDeletedYears,
		T.CustomRuleId,
		dDf.UserFileId,
		dDF.FolderId as FolderId
FROM cteDeletedDF dDF
INNER JOIN dbo.UserFile DF with(nolock)
	on dDF.FolderId = df.FolderId
	 and dDF.UserFileId = Df.UserFileId
LEFT JOIN dbo.UserFileExtension dfe with(nolock)
	on df.[ExtensionId] = dfe.[ExtensionId]
CROSS JOIN #companyCustomRules T
WHERE
  (
	EXISTS
		(
		SELECT TOP 1
				1 as id
		 where T.RuleType = 0
			and T.RuleCondition = 0
			and T.RuleItemFileType = dfe.[FileTypeId]

		 union all

		SELECT TOP 1
				1
		 where T.RuleType = 0
			and T.RuleCondition = 1
			and T.RuleItemFileType <> dfe.[FileTypeId]

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 0
			and DF.Name = T.RuleItemFileMask

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 4
			and DF.Name like  case T.RuleCondition
							  when 4
							  then '%' + T.RuleItemFileMask + '%' --never will be indexed
							  when 3
							  then '%' + T.RuleItemFileMask --never will be indexed
							  when 2
							  then T.RuleItemFileMask + '%' --may be indexed
							 end

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 5
			and dbo.RegExMatch(DF.Name, T.RuleItemFileMask) = 1 --never will be indexed

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 2
			and T.RuleCondition = 6
			and DF.[Length] > T.RuleItemFileSize

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 2
			and T.RuleCondition = 7
			and DF.[Length] < T.RuleItemFileSize

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 3
			and T.RuleCondition = 0
			and dDF.VirtualFolderId = T.RuleItemVirtualFolderId

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 3
			and T.RuleCondition = 8
			and T.RuleItemVirtualFolderOwnerId = dDf.OwnerId
		)
  )
)