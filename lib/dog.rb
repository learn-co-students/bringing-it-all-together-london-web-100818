class Dog

  attr_accessor :id, :name, :breed

  def initialize(name: name, breed: breed, id: id=nil)
    @name = name
    @breed = breed
    @id = nil
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = self.new
    new_dog.id = row[0]
    new_dog.name =  row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE dogs.id = ?;
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(hash)
       dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])
       if !dog.empty?
           Dog.new_from_db(dog[0])
       else
           self.create(hash)
       end
   end 

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE dogs.id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

end
