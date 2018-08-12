SELECT * INTO rsarkis.active_churn
FROM
  (WITH active_user AS
     (SELECT DAY,
             COUNT(DISTINCT user_id) AS active_user
      FROM source_data.tasks_used_da
      JOIN
        (SELECT DISTINCT date AS DAY
         FROM source_data.tasks_used_da) ON date BETWEEN DAY - interval '28 days' AND DAY
      WHERE sum_tasks_used > 0
      GROUP BY 1),
        daily_churn AS
     (SELECT DISTINCT date AS DAY,
                      user_id
      FROM source_data.tasks_used_da
      WHERE sum_tasks_used > 0 ) SELECT au.day AS date,
                                        au.active_user,
                                        COUNT(DISTINCT yesterday.user_id) AS churn_user
   FROM daily_churn yesterday
   LEFT JOIN daily_churn today ON today.user_id = yesterday.user_id
   AND today.day = yesterday.day + interval '28 days'
   JOIN active_user au ON yesterday.day=au.day
   WHERE today.user_id IS NULL
   GROUP BY 1,
            2
   ORDER BY 1);