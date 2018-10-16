require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(name: name, breed: breed, id: id=nil)
        @name = name
        @breed = breed
        @id = nil
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL
        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE dogs.id = ?;
        SQL
        DB[:conn].execute(sql, @name, @breed, @id)
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.id = ?;
        SQL
        Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.name = ?;
        SQL
        Dog.new_from_db(DB[:conn].execute(sql, name)[0])
        #binding.pry
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])
        if !dog.empty?
            Dog.new_from_db(dog[0])
        else
            self.create(hash)
        end
    end 

    def self.new_from_db(row)
        dog = Dog.new()
        dog.name = row[1]
        dog.breed = row[2]
        dog.id = row[0]
        dog
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
    end

end