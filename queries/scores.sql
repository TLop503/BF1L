-- Query to map driver race results to players for the completed races

SELECT 
    rw.weekend_id,
    rw.race_name,
    r.race_id,
    r.race_date,
    p.player_id,
    p.name AS player_name,
    t.team_id,
    t.team_name,
    d.driver_id,
    CONCAT(d.first_name, ' ', d.last_name) AS driver_name,
    dr.starting_position,
    dr.finishing_position,
    (dr.starting_position - dr.finishing_position) AS position_delta,
    dr.fia_points,
    CASE
        WHEN dr.finishing_position = 1 THEN 'Winner'
        WHEN dr.dnf = 1 THEN 'DNF'
        WHEN dr.dns = 1 THEN 'DNS'
        WHEN dr.notes = 'Disqualified' THEN 'DSQ'
        ELSE NULL
    END AS special_status,
    dr.laps_completed
FROM 
    DriverResults dr
JOIN 
    Drivers d ON dr.driver_id = d.driver_id
JOIN 
    Races r ON dr.race_id = r.race_id
JOIN 
    RaceWeekends rw ON r.weekend_id = rw.weekend_id
LEFT JOIN 
    Team_Drivers td ON d.driver_id = td.driver_id AND td.is_active = 1
LEFT JOIN 
    Teams t ON td.team_id = t.team_id
LEFT JOIN 
    Players p ON t.player_id = p.player_id
WHERE 
    r.race_id IN (1, 2)  -- The two races that have data
    AND r.event_status = 'COMPLETED'
ORDER BY 
    r.race_date DESC,
    dr.finishing_position ASC;

-- Alternative query that focuses on player performance by summing up points
SELECT 
    p.player_id,
    p.name AS player_name,
    t.team_id,
    t.team_name,
    r.race_id,
    rw.race_name,
    r.race_date,
    GROUP_CONCAT(CONCAT(d.first_name, ' ', d.last_name) SEPARATOR ', ') AS drivers,
    SUM(dr.fia_points) AS total_fia_points,
    SUM(dr.starting_position - dr.finishing_position) AS total_position_delta,
    SUM(dr.laps_completed) AS total_lap_points,
    COUNT(CASE WHEN dr.finishing_position = 1 THEN 1 END) AS wins,
    COUNT(CASE WHEN dr.dnf = 1 THEN 1 END) AS dnfs
FROM 
    Players p
JOIN 
    Teams t ON p.player_id = t.player_id
JOIN 
    Team_Drivers td ON t.team_id = td.team_id AND td.is_active = 1
JOIN 
    Drivers d ON td.driver_id = d.driver_id
LEFT JOIN 
    DriverResults dr ON d.driver_id = dr.driver_id
LEFT JOIN 
    Races r ON dr.race_id = r.race_id
LEFT JOIN 
    RaceWeekends rw ON r.weekend_id = rw.weekend_id
WHERE 
    r.race_id IN (1, 2)  -- The two races that have data
    AND r.event_status = 'COMPLETED'
GROUP BY 
    p.player_id, t.team_id, r.race_id
ORDER BY 
    r.race_date DESC,
    total_fia_points DESC;

-- Third query: Overall player standings with cumulative totals across all races
SELECT 
    p.player_id,
    p.name AS player_name,
    t.team_id,
    t.team_name,
    COUNT(DISTINCT r.race_id) AS races_participated,
    SUM(dr.fia_points) AS cumulative_fia_points,
    SUM(dr.starting_position - dr.finishing_position) AS cumulative_position_delta,
    SUM(dr.laps_completed) AS cumulative_laps_completed,
    COUNT(CASE WHEN dr.finishing_position = 1 THEN 1 END) AS total_wins,
    COUNT(CASE WHEN dr.dnf = 1 THEN 1 END) AS total_dnfs,
    -- Calculate cumulative total score
    SUM(dr.fia_points) * 2 + 
    SUM(dr.starting_position - dr.finishing_position) + 
    SUM(dr.laps_completed) AS cumulative_score
FROM 
    Players p
JOIN 
    Teams t ON p.player_id = t.player_id
JOIN 
    Team_Drivers td ON t.team_id = td.team_id AND td.is_active = 1
JOIN 
    Drivers d ON td.driver_id = d.driver_id
LEFT JOIN 
    DriverResults dr ON d.driver_id = dr.driver_id
LEFT JOIN 
    Races r ON dr.race_id = r.race_id
WHERE 
    r.event_status = 'COMPLETED'
GROUP BY 
    p.player_id, t.team_id
ORDER BY 
    cumulative_score DESC;
