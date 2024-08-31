DROP DATABASE IF EXISTS cmsc461_personal_project;
CREATE DATABASE cmsc461_personal_project;
USE cmsc461_personal_project;



create table associate
	(associate_id		numeric(6,0),
	 first_name		varchar(50),
	 last_name		varchar(50),
     hired_date     varchar(50),
     street         varchar(50),
     city           varchar(50),
     state          varchar(50),
     zipcode        numeric(5,0),
     unit_number    numeric(5,0),
     telephone_type varchar(50),
     telephone_number numeric(10,0),
     num_properties numeric(2,0) CHECK (num_properties <= 12),
     primary key (associate_id)
	);   
    
    
    
create table partner
	(partner_id		numeric(6,0),
	 first_name		varchar(50),
	 last_name		varchar(50),
     hired_date     varchar(50),
     street         varchar(50),
     city           varchar(50),
     state          varchar(50),
     zipcode        numeric(5,0),
     unit_number    numeric(5,0),
     telephone_type varchar(50),
     telephone_number numeric(10,0),
     num_contracts numeric(2,0),
     primary key (partner_id)
	);   
    
    
    
create table property_client
	(client_id		numeric(6,0),
	 first_name		varchar(50),
	 last_name		varchar(50),
     street         varchar(50),
     city           varchar(50),
     state          varchar(50),
     zipcode        numeric(5,0),
     unit_number    numeric(5,0),
     telephone_type varchar(50),
     telephone_number numeric(10,0),
     property_preferences varchar(50),
     max_rent numeric(7,0),
     primary key (client_id)
	);   
    
    
    
create table rental_property
	(rental_id		numeric(6,0),
     street         varchar(50),
     city           varchar(50),
     state          varchar(50),
     zipcode        numeric(5,0),
     unit_number    numeric(5,0),
     property_type    varchar(50),
     number_bedrooms    numeric(3,0),
     number_bathrooms    numeric(3,0),
     area_square_footage    numeric(7,0),
     monthly_rent    numeric(7,0),
     monthly_management_fee    numeric(7,0),
     adv    tinyint,
     primary key (rental_id)
	); 
    
    
    
create table property_owner
	(owner_id	numeric(6,0),
    first_name    varchar(50),
    last_name    varchar(50),
     street         varchar(50),
     city           varchar(50),
     state          varchar(50),
     zipcode        numeric(5,0),
     unit_number    numeric(5,0),
     telephone_type varchar(50),
     telephone_number numeric(10,0),
     primary key (owner_id)
	);  
    
    

create table viewing_for_property
	(viewing_id	numeric(6,0),
    rental_id numeric(6,0),
    associate_id numeric(6,0),
    client_id numeric(6,0),
    the_date date,
    the_time varchar(50),
	primary key (viewing_id),
    foreign key (rental_id) references rental_property(rental_id),
    foreign key (associate_id) references associate(associate_id),
    foreign key (client_id) references property_client(client_id)
	);   
    
   
   
create table managed_by
	(associate_id	numeric(6,0),
    rental_id numeric(6,0),
	primary key (associate_id, rental_id),
    foreign key (associate_id) references associate(associate_id),
    foreign key (rental_id) references rental_property(rental_id)
	);   
    
    
    
create table owned_by
	(rental_id	numeric(6,0),
    owner_id numeric(6,0),
	primary key (rental_id, owner_id),
    foreign key (rental_id) references rental_property(rental_id),
    foreign key (owner_id) references property_owner(owner_id)
	);   
    
    
    
create table email
	(email_id	numeric(6,0),
    email varchar(50),
    client_id numeric(6,0),
    owner_id numeric(6,0),
    associate_id numeric(6,0),
    partner_id numeric(6,0),
	primary key (email_id),
    foreign key (client_id) references property_client(client_id),
    foreign key (owner_id) references property_owner(owner_id),
    foreign key (associate_id) references associate(associate_id),
    foreign key (partner_id) references partner(partner_id)
	);  
    


create table lease
	(lease_id	numeric(6,0),
    client_id numeric(6,0),
    owner_id numeric(6,0),
    partner_id numeric(6,0),
    rental_id numeric(6,0),
    the_date varchar(50),
    monthly_rent numeric(6,0),
    deposit numeric(6,0),
    lease_duration varchar(50),
    start_date date,
    end_date date,
	primary key (lease_id),
    foreign key (client_id) references property_client(client_id),
    foreign key (owner_id) references property_owner(owner_id),
    foreign key (partner_id) references partner(partner_id),
    foreign key (rental_id) references rental_property(rental_id)
	);   



CREATE INDEX idx_associate_last_name ON associate (last_name);
CREATE INDEX idx_partner_last_name ON partner (last_name);
CREATE INDEX idx_property_owner_last_name ON property_owner (last_name);
CREATE INDEX idx_property_client_last_name ON property_client (last_name);
CREATE INDEX idx_viewing_for_property_date_and_time ON viewing_for_property (the_date, the_time);
CREATE INDEX idx_rental_property_bedrooms_bathrooms_area_square_footage ON rental_property (number_bedrooms, number_bathrooms, area_square_footage);


SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;