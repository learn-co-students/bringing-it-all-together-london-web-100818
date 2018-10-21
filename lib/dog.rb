require 'pry'
class Dog


  attr_accessor :name, :breed, :id

  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

    def save
      if self.id
        update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(dog_hash)
      new_dog = Dog.new(name: dog_hash[:name], breed: dog_hash[:breed])
      new_dog.save
      new_dog
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?;
      SQL
      find_dog = DB[:conn].execute(sql, id)[0]
      new_from_db(find_dog)
    end

    def self.new_from_db(dog_arr)
      new_dog = Dog.new(id: dog_arr[0], name: dog_arr[1], breed: dog_arr[2])
    end

    def self.find_or_create_by(dog_hash)
    # dog_from_db = Dog.find_or_create_by({name: 'teddy', breed: 'cockapoo'})


      sql_check = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed =  ?;
      SQL

        hold = DB[:conn].execute(sql_check, dog_hash[:name], dog_hash[:breed])[0]

      if hold != nil
          new_from_db(hold)
        elsif hold == nil
          create(dog_hash)
      end
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end




  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    by_name = DB[:conn].execute(sql, name)[0]

    new_from_db(by_name)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.all
    @@all
  end


end
