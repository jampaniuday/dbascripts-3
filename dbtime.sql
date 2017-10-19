-- instance's dbtime
SELECT *
FROM (SELECT A.INSTANCE_NUMBER,
    A.SNAP_ID,
    B.BEGIN_INTERVAL_TIME + 0 BEGIN_TIME,
    B.END_INTERVAL_TIME + 0 END_TIME,
    ROUND(VALUE - LAG(VALUE, 1, '0')
        OVER(ORDER BY A.INSTANCE_NUMBER, A.SNAP_ID),
        2) "DB TIME"
    FROM (SELECT B.SNAP_ID,
        INSTANCE_NUMBER,
        SUM(VALUE) / 1000000 / 60 VALUE
        FROM DBA_HIST_SYS_TIME_MODEL B
        WHERE B.DBID = (SELECT DBID FROM V$DATABASE)
        AND UPPER(B.STAT_NAME) IN UPPER(('DB TIME'))
        GROUP BY B.SNAP_ID, INSTANCE_NUMBER) A,
    DBA_HIST_SNAPSHOT B
    WHERE A.SNAP_ID = B.SNAP_ID
    AND B.DBID = (SELECT DBID FROM V$DATABASE)
    AND B.INSTANCE_NUMBER = A.INSTANCE_NUMBER)
WHERE BEGIN_TIME > SYSDATE - &days-- and INSTANCE_NUMBER = 4
ORDER BY 1,3 desc;
