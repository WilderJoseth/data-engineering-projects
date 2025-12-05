

EXEC study_space_missions_db.usp_start_process

EXEC study_space_missions_db.usp_end_process 1

EXEC study_space_missions_db.usp_start_sub_run 1, 'BRONZE', 10

EXEC study_space_missions_db.usp_end_sub_run 1, 'BRONZE', 5

SELECT * FROM study_space_missions_db.runs
ORDER BY id DESC

SELECT * FROM study_space_missions_db.sub_runs
WHERE run_id = 27

SELECT * FROM study_space_missions_db.logs
WHERE run_id = 27
