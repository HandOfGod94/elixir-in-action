defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message ->
        process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})

    receive do
      {:todo_entries, entries} -> entries
    after 5000 ->
      {:error, :timeout}
    end
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  defp process_message(todo_list,  {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry) 
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

end

defmodule TodoList do
  def new do
    Map.new()
  end

  def add_entry(todo_list, entry) do
    Map.update(
      todo_list,
      entry.date,
      [entry.title],
      &[entry.title | &1]
    )
  end

  def entries(todo_list, date) do
    Map.get(todo_list, date, [])
  end
end
