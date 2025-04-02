SELECT 
    T.team_id,
    T.team_name,
    P.player_id,
    P.draft_points,
    P.name AS player_name,
    P.draft_points,
    D.driver_id,
    CONCAT(D.first_name, ' ', D.last_name) AS driver_name,
    D.car_number,
    TD.draft_date,
    TD.end_date,
    TD.is_active
FROM Teams T
LEFT JOIN Players P ON P.player_id = T.player_id
LEFT JOIN Team_Drivers TD ON T.team_id = TD.team_id
LEFT JOIN Drivers D ON TD.driver_id = D.driver_id
ORDER BY T.team_id, TD.is_active DESC, TD.draft_date;
