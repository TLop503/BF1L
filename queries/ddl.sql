-- Drop Existing Tables if They Exist
DROP TABLE IF EXISTS Players, Teams, Drivers, WeeklyTeamResults, Races, DriverResults, Team_Drivers;

-- Create Player Table
CREATE TABLE Players(
    player_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    draft_points INT NOT NULL
);

-- Table for fantasy teams
CREATE TABLE Teams (
    team_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    player_id INT,
    FOREIGN KEY (player_id) REFERENCES Players(player_ID)
);

-- Drivers (real people)
CREATE TABLE Drivers (
    driver_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(32) NOT NULL,
    last_name VARCHAR(32) NOT NULL,
    car_number INT NOT NULL,
    irl_affiliation VARCHAR(32)
);

-- Intersection table of drivers and teams
-- Contains field for if this is an active or historical relationship
CREATE TABLE Team_Drivers (
    assignment_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    driver_id INT NOT NULL,
    draft_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN NOT NULL,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
);

-- Race weekends
-- weekend_id can also be its round number on the calendar
-- e.g., this year Albert Park in Australia is round one
CREATE TABLE RaceWeekends (
    weekend_id INT NOT NULL PRIMARY KEY,
    race_name VARCHAR(255),
    circuit_name VARCHAR(255),
    circuit_location VARCHAR(255) NOT NULL,
    has_sprint BOOLEAN NOT NULL
);

CREATE TABLE Races (
    race_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    weekend_id INT,
    race_type ENUM('SPRINT', 'GRAND_PRIX'),
    race_date DATE,
    event_status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED'),
    FOREIGN KEY (weekend_id) REFERENCES RaceWeekends(weekend_id)
);

-- Intersection table of drivers and races
CREATE TABLE DriverResults (
    driver_result_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    race_id INT,
    driver_id INT,
    starting_position INT,
    finishing_position INT,
    fia_points INT,
    laps_completed INT,
    dns BOOLEAN NOT NULL,
    dnf BOOLEAN NOT NULL,
    notes TEXT, -- in case of oddities like DQ or something
    FOREIGN KEY (race_id) REFERENCES Races(race_id),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
);